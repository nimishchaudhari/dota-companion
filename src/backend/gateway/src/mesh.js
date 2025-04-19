const { getMesh } = require('@graphql-mesh/runtime');
const { join } = require('path');
const { readFileSync } = require('fs');
const { parse } = require('graphql');
const config = require('./config');
const logger = require('./utils/logger');

/**
 * Get mesh options for integrating OpenDota and STRATZ APIs
 */
async function getMeshOptions() {
  const localSchema = readFileSync(join(__dirname, './schema/schema.graphql'), 'utf8');
  
  return {
    // Custom local schema
    sources: [
      {
        name: 'LocalSchema',
        handler: {
          graphql: {
            typeDefs: localSchema,
            useGETForQueries: true,
          }
        }
      },
      // OpenDota API
      {
        name: 'OpenDota',
        handler: {
          jsonSchema: {
            baseUrl: config.opendota.baseUrl,
            operations: [
              {
                type: 'Query',
                field: 'heroStats',
                path: '/heroStats',
                method: 'GET',
                responseSchema: './openDotaSchemas/heroStats.json'
              },
              {
                type: 'Query',
                field: 'matches',
                path: '/matches/{args.match_id}',
                method: 'GET',
                responseSchema: './openDotaSchemas/match.json'
              },
              {
                type: 'Query',
                field: 'playerMatches',
                path: '/players/{args.account_id}/matches',
                method: 'GET',
                responseSchema: './openDotaSchemas/playerMatches.json'
              }
            ],
            operationHeaders: {
              'api-key': config.opendota.apiKey
            }
          }
        },
        transforms: [
          {
            rename: {
              renames: [
                {
                  from: {
                    type: 'Query',
                    field: 'heroStats'
                  },
                  to: {
                    type: 'Query',
                    field: 'openDotaHeroStats'
                  }
                },
                {
                  from: {
                    type: 'Query',
                    field: 'matches'
                  },
                  to: {
                    type: 'Query',
                    field: 'openDotaMatch'
                  }
                },
                {
                  from: {
                    type: 'Query',
                    field: 'playerMatches'
                  },
                  to: {
                    type: 'Query',
                    field: 'openDotaPlayerMatches'
                  }
                }
              ]
            }
          }
        ]
      },
      // STRATZ API
      {
        name: 'STRATZ',
        handler: {
          graphql: {
            endpoint: 'https://api.stratz.com/graphql',
            operationHeaders: {
              'Authorization': `Bearer ${config.stratz.apiKey}`
            }
          }
        },
        transforms: [
          {
            filterSchema: {
              filters: [
                'Query.{hero,heroes,player,players,match,matches}*',
                'Hero*',
                'Player*',
                'Match*',
                'Draft*'
              ]
            }
          },
          {
            rename: {
              renames: [
                {
                  from: {
                    type: 'Query',
                    field: 'hero'
                  },
                  to: {
                    type: 'Query',
                    field: 'stratzHero'
                  }
                },
                {
                  from: {
                    type: 'Query',
                    field: 'heroes'
                  },
                  to: {
                    type: 'Query',
                    field: 'stratzHeroes'
                  }
                },
                {
                  from: {
                    type: 'Query',
                    field: 'match'
                  },
                  to: {
                    type: 'Query',
                    field: 'stratzMatch'
                  }
                },
                {
                  from: {
                    type: 'Query',
                    field: 'matches'
                  },
                  to: {
                    type: 'Query',
                    field: 'stratzMatches'
                  }
                },
                {
                  from: {
                    type: 'Query',
                    field: 'player'
                  },
                  to: {
                    type: 'Query',
                    field: 'stratzPlayer'
                  }
                },
                {
                  from: {
                    type: 'Query',
                    field: 'players'
                  },
                  to: {
                    type: 'Query',
                    field: 'stratzPlayers'
                  }
                }
              ]
            }
          }
        ]
      }
    ],
    // Additional plugins and configurations
    plugins: [],
    cache: config.env === 'production' ? {
      localforage: {
        driver: 'MEMORY'
      }
    } : false,
    debug: config.env === 'development'
  };
}

/**
 * Get the GraphQL schema from Mesh
 */
async function getSchema(meshOptions) {
  try {
    logger.info('Building GraphQL schema...');
    const { schema, rawSources } = await getMesh(meshOptions);
    logger.info('GraphQL schema built successfully');
    return { schema, rawSources };
  } catch (error) {
    logger.error('Failed to build GraphQL schema:', error);
    throw error;
  }
}

/**
 * Get the Mesh SDK for executing operations
 */
async function getMeshSDK({ schema, rawSources }) {
  // Custom resolvers for the local schema
  const resolvers = {
    Query: {
      draftSuggestions: async (_, { state }, context) => {
        try {
          const { team, enemyTeam, availableHeroes, currentPick } = state;
          
          // Get hero stats from OpenDota
          const heroStats = await context.OpenDota.Query.openDotaHeroStats();
          
          // Get hero data from STRATZ for counters
          const heroesData = await context.STRATZ.Query.stratzHeroes();
          
          // Calculate counters and synergies based on data
          const suggestions = calculateDraftSuggestions(
            heroStats,
            heroesData,
            team,
            enemyTeam,
            availableHeroes,
            currentPick
          );
          
          return suggestions;
        } catch (error) {
          logger.error('Error in draftSuggestions resolver:', error);
          throw error;
        }
      },
      
      liveCoachPing: async (_, { frame }, context) => {
        try {
          // Forward the frame to the LLM Proxy service
          const response = await fetch(`${config.llmProxy.url}/v1/llm/chat`, {
            method: 'POST',
            headers: {
              'Content-Type': 'application/json',
            },
            body: JSON.stringify({
              frame,
              user: context.user,
            }),
          });
          
          if (!response.ok) {
            const error = await response.json();
            throw new Error(`LLM Proxy error: ${error.message}`);
          }
          
          return response.json();
        } catch (error) {
          logger.error('Error in liveCoachPing resolver:', error);
          throw error;
        }
      },
    },
  };
  
  // Add the custom resolvers to the schema
  schema = addResolversToSchema(schema, resolvers);
  
  return getMeshSDKFromSchema(schema, rawSources);
}

/**
 * Helper function to calculate draft suggestions
 */
function calculateDraftSuggestions(heroStats, heroesData, team, enemyTeam, availableHeroes, currentPick) {
  // Implementation details for calculating counters and synergies
  // This is a placeholder for the actual implementation
  
  return {
    counters: [
      { heroId: 1, name: 'Anti-Mage', advantage: 5.2, sampleSize: 1200 },
      { heroId: 2, name: 'Axe', advantage: 4.8, sampleSize: 980 },
      { heroId: 3, name: 'Bane', advantage: 4.5, sampleSize: 750 },
      { heroId: 4, name: 'Bloodseeker', advantage: 4.1, sampleSize: 820 },
      { heroId: 5, name: 'Crystal Maiden', advantage: 3.9, sampleSize: 900 },
    ],
    synergies: [
      { heroId: 6, name: 'Drow Ranger', synergy: 3.8, sampleSize: 800 },
      { heroId: 7, name: 'Earthshaker', synergy: 3.5, sampleSize: 750 },
      { heroId: 8, name: 'Juggernaut', synergy: 3.2, sampleSize: 900 },
    ],
    recommendations: [
      { heroId: 1, name: 'Anti-Mage', score: 85 },
      { heroId: 6, name: 'Drow Ranger', score: 82 },
      { heroId: 2, name: 'Axe', score: 78 },
    ],
  };
}

module.exports = {
  getMeshOptions,
  getSchema,
  getMeshSDK,
};

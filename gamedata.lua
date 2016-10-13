-- gamedata.lua
--	babyjeans
--
-- location for tables / scripts to build gameplay data
---
local WorldBuilder = require('script/game/builder')


EntityPath = 'script/game/'

---
-- Global Game Data
ResourceList = { }
WorldMapData = { }

---
-- Static data / settings
GameSettings = {
	Colors = {
		Darkest  = {  28,  33,   3, 255 },
		Dark     = {  86,  96,  31, 255 },
		Light    = { 167, 178, 112, 255 },
		Lightest = { 235, 239, 215, 255 },

        darkest  = {  28,  33,   3, 255 },
        dark     = {  86,  96,  31, 255 },
        light    = { 167, 178, 112, 255 },
        lightest = { 235, 239, 215, 255 },
	},

	Screen = { 
		Scale      = 4,
		Resolution = { w = 160, h = 144 },
		ScreenSize = { w = 640, h = 576 },	-- yeah that's a given, i know.
	},

	Controls = { 
		Left  = { 'left', },
		Right = { 'right', },
		Up    = { 'up', },
		Down  = { 'down', },

		Primary   = { 'z', },
		Secondary = { 'x', },

		Start  = { 'enter', 'return' },
		Select = { 'space', },
		Escape = { 'escape', },
	},

	Defaults = {
	},
}

PotionIngredients = {
	['berry'] = { texture='Berry', cost=20,  appease=2,  sell=5,  combine = { ['stick'] = { appease = 0, sell=2} } },
	['stick'] = { texture='Stick', cost=30,  appease=2,  sell=7,  combine = { } },
	['eye']   = { texture='Eye',   cost=30,  appease=10, sell=10, combine = { } },
	['bone']  = { texture='Bone',  cost=100, appease=5,  sell=20, combine = { ['stick'] = { appease = -1, sell=-5 }, ['eye'] = { appease=2, sell=10 } } }
}

PotionRecipes = {
	{ name="Bone Broth",  recipe = { 'bone', 'bone'            } },
	{ name="Juice",       recipe = { 'berry'                   } },
	{ name="Froth Broth", recipe = { 'berry', 'bone', 'bone',  } },
	{ name='Rat Trap',	  recipe = { 'berry', 'stick'          } },
	{ name="Berry Tea",   recipe = { 'berry', 'berry', 'stick' } },
}

----
-- Game Data Initialization
--- 
-- Most stuff happens on a lookup, but we let the tables get created in initGameData so I have control over
-- 'when' it happens. Some of the builders may use more of love than can be expected on initial boot.
function initGameData()

	-- Game Resource List, arranged by 'stage' to load
	-- TODO: Support table nesting
	---

	ResourceList = {
		fonts = {
			font               = {      'font', 'assets/fnt/04B_03__.ttf',                           8           },
			bigFont            = {      'font', 'assets/fnt/04B_03__.ttf',                          16           },
			hugeFont           = {      'font', 'assets/fnt/04B_03__.ttf',                          24           },
			copyright          = {     'image', 'assets/fnt/copyright-small.png'                                 },
		},        

  		menu = {        
   			logo               = {     'image', 'assets/gfx/menu-logo.png'                                       },
   		},        

		brewUI = {        
			menuTop            = {     'image', 'assets/gfx/brewui-menu-top.png'                                 },
			menuMiddle         = {     'image', 'assets/gfx/brewui-menu-middle.png'                              },
			menuMiddleTop      = {     'image', 'assets/gfx/brewui-menu-middle-top.png'                          },
			menuMiddleMid      = {     'image', 'assets/gfx/brewui-menu-middle-mid.png'                          },
			menuMiddleBot      = {     'image', 'assets/gfx/brewui-menu-middle-bot.png'                          },
			
			menuBottom         = {     'image', 'assets/gfx/brewui-menu-bottom.png'                              },
                      
      		inventorySlotUp    = {     'image', 'assets/gfx/brewui-inventoryslot-up.png'                         },
      		inventorySlotDown  = {     'image', 'assets/gfx/brewui-inventoryslot-down.png'                       },
    		inventoryBerry     = {     'image', 'assets/gfx/brewui-inventory-berry.png'                          },
    		inventoryStick     = {     'image', 'assets/gfx/brewui-inventory-stick.png'                          },
    		inventoryBone      = {     'image', 'assets/gfx/brewui-inventory-bone.png'                           },
    		inventoryEye       = {     'image', 'assets/gfx/brewui-inventory-eye.png'                            },

      		recipeSlotUp       = {     'image', 'assets/gfx/brewui-recipeslot-up.png'                            },
      		recipeSlotDown     = {     'image', 'assets/gfx/brewui-recipeslot-down.png'                          },
			recipeBerry        = {     'image', 'assets/gfx/brewui-recipe-berry.png'                             },
			recipeStick        = {     'image', 'assets/gfx/brewui-recipe-stick.png'                             },
			recipeBone         = {     'image', 'assets/gfx/brewui-recipe-bone.png'                              },
			recipeEye          = {     'image', 'assets/gfx/brewui-recipe-eye.png'                               },

			brewButton         = {     'image', 'assets/gfx/brewui-cauldron-brewbutton.png'                      },
			cauldronIdle       = {     'image', 'assets/gfx/brewui-cauldron-idle.png'                            },
			cauldronCanBrew    = { 'animation', 'assets/gfx/brewui-cauldron-canbrew.png',          8,  12        },
			cauldronBrewing    = { 'animation', 'assets/gfx/brewui-cauldron-brewing.png',          8,  12        },
			cauldronSuccess    = { 'animation', 'assets/gfx/brewui-cauldron-brewing-success.png', 32,  12, false },
			cauldronFail       = { 'animation', 'assets/gfx/brewui-cauldron-brewing-fail.png',    29,  12, false },
			cauldronPotion     = { 'animation', 'assets/gfx/brewui-cauldron-potion.png',          10,  12, false },
			potion             = { 'animation', 'assets/gfx/brewui-potion.png',                    4,  8         },
		},

		brewWitch = {        
			idle               = {     'image', 'assets/gfx/brewWitch.png'                                       },
			searching          = { 'animation', 'assets/gfx/brewWitch-anim-search.png',           8,  20         },
			walk               = { 'animation', 'assets/gfx/brewWitch-anim-walk.png',             5,  12         },
		},        

		witchHouse = {        
			outside            = {     'image', 'assets/gfx/witchHouse-exterior.png'                             },
			interiorLvl1       = {     'image', 'assets/gfx/witchHouse-interior_lvl_1.png'                       },
			bed                = {     'image', 'assets/gfx/witchHouse-prop-bed.png'                             },
			counter            = {     'image', 'assets/gfx/witchHouse-prop-counter.png'                         },
			cauldron           = {     'image', 'assets/gfx/witchHouse-prop-cauldron.png'                        },
		},        

		forest = {        
			tree               = {     'image', 'assets/gfx/tree-flat.png'                                       },
			dither             = {     'image', 'assets/gfx/background-skyDither.png'                            },
			parallax           = {     'image', 'assets/gfx/background-parallax.png'                             },
			ground1            = {     'image', 'assets/gfx/forest-ground1.png'                                  },
			ground2            = {     'image', 'assets/gfx/forest-ground2.png'                                  },
			ground3            = {     'image', 'assets/gfx/forest-ground3.png'                                  },
			ground4            = {     'image', 'assets/gfx/forest-ground4.png'                                  },
			ground5            = {     'image', 'assets/gfx/forest-ground5.png'                                  },
			ground6            = {     'image', 'assets/gfx/forest-ground6.png'                                  },
			ground7            = {     'image', 'assets/gfx/forest-ground7.png'                                  },
			ground8            = {     'image', 'assets/gfx/forest-ground8.png'                                  },
			ground9            = {     'image', 'assets/gfx/forest-ground9.png'                                  },
			ground10           = {     'image', 'assets/gfx/forest-ground10.png'                                 },
		},        

		cave = {        
			dither             = {     'image', 'assets/gfx/background-caveDither.png'                           },
			crack1             = {     'image', 'assets/gfx/background-caveCrack1.png'                           },
			crack2             = {     'image', 'assets/gfx/background-caveCrack2.png'                           },
			crack3             = {     'image', 'assets/gfx/background-caveCrack3.png'                           },
			crack4             = {     'image', 'assets/gfx/background-caveCrack4.png'                           },
			ground1            = {     'image', 'assets/gfx/cave-ground1.png'                                    },
		},
	
		--TO CREATE:

		-- World:
		--   Cave assets
		--   Ingredients
		--   Town Assets
		-- 	   Town People
		
		ui = {
			magicIcon          = {     'image', 'assets/gfx/ui-murray.png'                             },
			magicBarBack       = {     'image', 'assets/gfx/ui-magicBar-empty.png'                     },
			magicBarFill       = {     'image', 'assets/gfx/ui-magicBar-fill.png'                      },

			divider            = {     'image', 'assets/gfx/ui-divider.png'                            },
			endCap             = {     'image', 'assets/gfx/ui-endcap.png'                             },
			bar                = {     'image', 'assets/gfx/ui-bar.png'                                },

			countX             = {     'image', 'assets/gfx/ui-x.png'                                  },
			coin               = {     'image', 'assets/gfx/ui-coin.png'                               },
			keyUp              = {     'image', 'assets/gfx/ui-key-up.png'                             },
			keyDown            = {     'image', 'assets/gfx/ui-key-down.png'                           },

			cursor             = {     'image', 'assets/gfx/ui-cursor.png'                             },
		},
		-- UI:
		--   27 segments to the magic bar
		--   x
		--   numbers
		--   ingredient icons
	}

end


function initWorldData(resources) --make sure stuff is staged
	local groundTable = {
		cave = {
			resources.cave.ground1,
		},
		forest = {
			resources.forest.ground1,
			resources.forest.ground2,
			resources.forest.ground3,
			resources.forest.ground4,
			resources.forest.ground5,
			resources.forest.ground6,
			resources.forest.ground7,
			resources.forest.ground8,
			resources.forest.ground9,
			resources.forest.ground10,
		},
		field = { },
		roughVillage = { },
		village = { },
		grassland = { },
		beach = { },
		ocean = { },
	}
	resources.GroundTable = groundTable

    WorldMapData = {
 --[[       WorldBuilder("Cave")
            :setGroundTable(groundTable.cave)
            :setDither(resources.cave.dither, 62)
            :addEnv(resources.cave.crack1,   2,  85)
            :addEnv(resources.cave.crack2,  41, 100)
            :addEnv(resources.cave.crack3,  93, 114)
            :addEnv(resources.cave.crack4, 119,  84)
            :addBgFill({ 
                    { 0, 62, 'dark' },
                    { 62, (144 - 62), 'darkest' }
                }),
     ]]       
		WorldBuilder("Forest")
			:setGroundTable(groundTable.forest)
			:setDither(resources.forest.dither, 41)
			:addBgFill({ 
					{ 0, 48, 'lightest' },
					{ 48, 96, 'light' }
				})
			:addParallax(resources.forest.parallax, { position = { -20, 'ground' }, speed = { -5, 0 } } )
			:addEnv(Resources.forest.tree, 74, 68)
			:addEntity('witchhouse', 4, 67)
			:setStartZone(5, 'ground'),
    }
end
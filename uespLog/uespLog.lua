-- uespLog.lua -- by Dave Humphrey, dave@uesp.net
-- AddOn for ESO that logs various game data for use on www.uesp.net
--
-- TODO:
--		- Display charges of weapon
--		- Better loot target/source logging
--			- GetLootTargetInfo() Returns: string name, InteractTargetType targetType, string actionName
--		- Extended loot display messages (level, trait, style)
--		- Display message when weapon charges run out
--		- "Item Info" menu for all crafting stations tooltips
--		- MAC Install Issue
--				- Remove utility folder?
--		- Yokudan style icon (35)?
--		- Akaviri style icon?
--		- Track NPC dialogue (link to quest?).
--
--
-- CHANGELOG:
--		v0.10 - 30 March 2014
--			- First release (earlier versions were for beta)
--
--		v0.11 - 31 March 2014
--			- Added a list of common NPCs to ignore (Rat, Mudcrab, Familiar, etc...)
--			- Removed inventory update message
--			- Fixed crash when using /uesplog on/off
--			- Tweaked some messages
--			- Gold looted and gold quest rewards are now logged
--
--		v0.11a - 31 March 2014
--			- Removed money messages used for testing
--
--		v0.12 - 8 April 2014
--			- Added /uesptime command
--			- Log change in skill points (for quest rewards)
--			- Now logs maximum HP/MG/ST for NPC targets
--			- Logs lock quality on chests
--			- Coordinates shown in bottom left on map in range (0,0) to (1,1)
--			- Added 'recipes' and 'achievements' options to /uespcount
--			- Added the 'extra' option to /uespdebug for testing purposes
--
--		v0.13 - 15 April 2014
--			- Shows inspiration for crafting events
--			- Shows the link for crafted items
--			- Added the /uespresearch command
--			- Added some messages in custom colors
--			- Added the /uespcolor on|off command
--			- uespLogMonitor: Fixed escape issue
--			- uespLogMonitor: Fixed issue not sending log entries with "blank" section in saved variable file
--			- uespLogMonitor: Log file is appended to and more things output to it
--			- uespLogMonitor: Added two file menu commands
--			- Fixed logging of target positions
--
--		v0.13a - 15 April 2014
--			- uespLogMonitor: Fixed incorrect use of blank account names
--
--		v0.14 - 2 May 2014
--			- Fixed item link/name display for crafted items
--			- Better logging of resource node positions
--			- Distinguish between group and self loot event
--			- Added estimated game time and moon phase for /uesptime
--			- Added /uespcount traits
--			- Added XP display and logging
--			- Improved display of item links
--			- Added MG/HP/ST/UT change display in debug output mode
--			- More colors (disable color messages with /uespcolor off)
--
--		v0.15 - 18 May 2014
--			- Added the "/uespdump smith|smithset" commands
--				- Dumps all smithable items to log when using an appropriate crafting station
--			- Adds a right-click "Link in Chat" menu option to popup item link
--			- Adds a right-click "Show Item Info" menu option on inventory lists and item popups
--			- Added the "/uespmakelink" (/uml) command 
--				- Format: /uespmakelink ID LEVEL SUBTYPE
--				- ID is required but LEVEL/SUBTYPE are optional
--				- For SUBTYPE description see http://www.uesp.net/wiki/User:Daveh/ESO_Notes#Item_Link_Format
--			- Fixed crash when looting some resources in non-english versions of the game
--			- Added the "/uespcharinfo" (/uci) command
--			- Added logging of veteran and alliance points
--			- Trade skill information display:
--				- Use "/uespcraft" to turn various components of the display on/off
--				- Shows provisioning level of ingredients in inventory lists and tooltips
--				- Color codes blue/purple ingredients
--				- Shows whether recipe is known or not in inventory lists (english only at the moment)
--				- Shows whether weapon/armor trait is known or not in inventory lists and tooltips
--				- Shows the item style in inventory lists and tooltips
--				- Provides a similar function as the Show Motifs add-on
--				- Compatible and similar function as the SousChef add-on
--				- Compatible and similar function as the ResearchAssistant add-on+
--			- In Testing: Added autolooting of provisioning ingredients:
--				- Only loot ingredients more than a specific level
--				- Auto loot all other items and money
--				- Turn off theloot in the game options to use
--				- Use "/uespcraft autoloot on/off" to enable (initially disabled)
--				- Use "/uespcraft minprovlevel [level]" to set which level of ingredients to autoloot
--				- Normal ingredient level is 1-6, 100 for blue ingredients and 101 for purple
--				- Displays a "Skipped..." message for items not looted
--				- Skipped provisioning items remain in the container
--
--		- v0.16 - 19 May 2014
--			- Fixed display of the "Show Item Info" menu item.
--			- Ingredient and style information shown in tooltip from a clicked item link (trait info can't be shown).
--			- Tweaked looting messages.
--			- Game language added to all log data.
--			- Footlockers now close properly when autoloot is on.
--
--		- v0.17 - 24 May 2014
--			- Always loot plump worms and crawdads (so flower nodes disappear when looted).
--			- Fix crash when autolooting quest items.
--			- Fixed display of pepper ingredient.
--			- Upgraded to 100004 API version for Craglorn.
--
--		- v0.18 - 2 July 2014
--			- Items linked in chat messages are logged.
--			- Items looted from mail messages are logged.
--			- Added a simple craft inspiration summation meter.
--				- Reset via: /uespreset inspiration
--				- Check via: /uespcount inspiration
--			- Item information shows the weapon and armor types.
--			- Added "/uesptime calibrate" to help with time calibration and testing.
--			- Improved the game time estimation.
--			- Changed API version to 100007.
--			- Added check to prevent NIL string outputs to log data.
--
--		- v0.19 - 21 August 2014
--			- Changed API version to 100008.
--			- Fixed crash when using "/uespdump inventory" due to API change.
--			- Fixed "nil string" crash bug due to strings over 1999 bytes being output to
--            the saved variable file. Long strings are split.
--
--		- v0.20 - 4 November 2014
--			- Fixed updated GetNumLastCraftingResultItemsAndPenalty() function.
--			- Updated API to 100010.
--			- Fix the CSV export utility.
--			- Attempted fix to replace the now remove 'reticleover' target position (uses the player position instead).
--			- Show item info fixed (updated new function names).
--
--		- v0.21 - 17 November 2014
--			- Fixed "/uespdump achievements" due to removed function.
--			- Fixed issue with facial animations.
--			- More conversation data is now logged.
--			- Added Dwemer style icon.
--			- The "Show Item Info" context menu works in more places now.
--			- "Show Item Info" displays much more item information.
--			- Much more item information is now logged.
--			- If you receive a "Low LUA Memory" warning you can try to increase the "LuaMemoryLimitMB" 
--			  parameter in the UserSettings.txt file.
--			- Dumping globals works better. Removed duplicate entries and unecessary objects. Userdata
-- 	          objects now dumped. Duplicate "classes" no longer dumped to save space.
--			- Dump globals now outputs the string for SI_* values.
--			- Added a method to iteratively dump all the global objects.
--					/uespdump globals [maxlevel]        -- Normal method all at once
--					/uespdump globals start [maxlevel]  -- Start iterative dumping
--					/uespdump globals stop              -- Stop iterative dumping
--					/uespdump globals status            -- Current status of iterative dump
--			- Started work on "/uespmineitems" (/umi) for mining item data. Use with caution as it can easily 
--			  crash your client. 
--						/uespmineitems [itemId]
--						/uespmineitems status
--						/uespmineitems start [startItemId]
-- 						/uespmineitems stop
--			  ItemIds are just numbers from 1-100000.
--			- BUG: Sometimes the saved variable data gets corrupted. This seems to occur during a global
--			  dump on rare occasions and is most likely an ESO/LUA engine bug. Use "/uespreset all" to
--			  clear the saved variable data back to an empty state which can usually fix this.
--			- Added short initialization message on startup.
--
--		- v0.22 - 11 March 2015
--			- Added "/uespmail deletenotify on|off" to turn the mail delete notification prompt on/off.
--			- Created item links use the item's name if available and valid.
--			- Added the "/uespcomparelink" (/ucl) command for testing item link comparisons.
--			- Added more data to the show item info output and item data logs.
--			- Warning is shown if any section data exceeds 65000 elements. The game seems to truncate
--			  arrays loaded from the saved variables to under ~65540 elements.
--			- Added the "/uespmineitem autostart [id]" mode. In this mode the item-miner will create 50000
--			  log entries before automatically reloading the UI, resetting the logged data and continuing.
--			  It will stop when you do "/uespmineitem stop" or the itemId reaches 100000.
--			- Changed color of item mining output to be more unique.
--			- Added the "/uespmineitem qualitymap".
--			- Added the "/uespmineitem subtype [number]" for only mining items of a certain type.
--			- Added the "/ut" shortcut for "/uesptime".
--			- Added the "/uespmakeenchant" (/ume) command.
--			- Fixed showing and logging of item trait abilities (crafted potions).
--			- Fixed crash on looting items from Update 6.
--			- Fixed crash due to renamed INTERACT_WINDOW object.
--			- Changed API version to 100011.
--			- Fixed issue with autolooting.
--
--		- v0.23 - 3 June 2015
--			- Fixed bug with Justice System / bounty error (no longer errors out when a guard acosts you).
--
--		- v0.24 - 27 July 2015
--			- Fixed item mining due to new item link format (1 more unknown data field).
--			- Added a basic settings menu using LibAddonMenu-2.0. Settings can
--			  be accessed through the game's Settings--Addon menu or via "/uespset".
--			- Bundled uespLogMonitor updated to v0.16 (minor performance based improvements). 
--			- Added the "/uespreset log" option to reset just the normal logged data section.
--			- Fixed display issue when turning crafting display on/off.
--			- Removed the autoloot function since ingredients don't have levels after update #6.
--			- Provisional ingredients updated from update #6.
--			- Item style text/icon only displayed for weapons and armors.
--			- Craft/trait/style info is now shown in the guild trader windows.
--			- Added the "/uespmineitems idcheck" command. Simply loops through all IDs and checks
--			  if it is a valid item or not and outputs a list of valid item ID ranges to the log.
--			- Added basic icons for Yokudan and Akaviri styles.
--			- Updated the experience messages. Veteran players will no longer receive the double
--			  experience debug message.
--			- Fixed game crash bug when trying to buy a horse.
--			- Fixed a game crash bug when using a quartermaster in Cyrodiil.
--			- Gold stolen from safeboxes will now be displayed.
--			- Shortened/tweaked the log message displayed in the chat window.
--			- Fixed the trait known/unknown display for nirnhoned items.
--
--		- v0.25 - 30 July 3015
--			- Add "/uespdump skills".
--			- Fix bug with negative xp values sometimes displayed.
--			- Added the "/uespenl" command to show the character's enlightenment pool.
--			- Added viewing of PVP events toggled by the "/uesppvp on/off" command (default is off).
--			  This is currently in testing and may be a bit spammy if you are in an active campaign.
--			- "/uesppvp showfights" will show all known fights in the current campaign.
--			- Fixed bug that results in a very large saved variable file.
--			- Fixed more crash bugs related to the guild store.
--			- Tweaked startup message.
--
--		- v0.26 - 31 July 2015
--			- Fixed another crash bug when the guild store is first opened.
--			- Style of rings and necklaces will no longer be shown.
--			- Item tooltips for stacks of items in the guild store include a "price per item" line.
--
--		- v0.30 - 30 Aug 2015
--			- Tweaked /uesptime output, added day of month and adjusted moon phase calculation.
--			- Online game time can be seen at: http://content3.uesp.net/esoclock/esoclock.php
--			- Update API version to 1000012.
--			- Telvar stones gained/lost will be shown if debug output is on.
--			- Added style icons for the new Glass/Xivkyn styles.
--			- Added the "/uespd [cmd]" (or "/ud [cmd]") command which is a short form for "/script d([cmd])".
--			- "/upf" is now a short form for "/uesppvp showfights".
--			- "/ue" is now a short form for "/uespenl".
--			- All colored text is closed by a "|r" to make sure it doesn't 'leak',
--			- Added known/unknown display to motif tooltips and rows.
-- 			- Tweak position of style/known icons in lists.
--			- Changed the skill dump command and output. Now outputs a lot more information to the log.
--			  Now has the format:
--				/uespdump skills 
--				/uespdump skills [basic/progression/learned/types/all] [note]
--
--		- v0.40 - 2 November 2015
--			- Ability icons are logged in skill dumps with the new GetAbilityIcon(abilityId) function.
--			- Added new item sub-types for V15/V16 equipment for item mining.
--			- Added some creatures to ignore from the Imperial City.
--			- "/uespdump globals" now works with private functions with numbers in their name.
--			- Trait display fixed for Nirnhoned items currently being researched.
--			- Tweaked looting messages and included Safeboxes in logged data.
--			- Added the /uesptreasuretimer (or /utt) for keeping track of looted containers. Once a
--			  container (chest, heavy sack, or safebox) is looted a timer will start and notify you
--			  with a chat message in a given amount of time. Current defaults are 2 minutes (120 sec)
--			  which works for chests in delves but may be too short for other containers in some zones.
--					/utt 					: Shows the current status
--					/utt [on/off]			: Turns the timer on/off (default is off)
--					/utt [name]				: Shows the timer length for the given container name.
--											: Valid names are: Chest, Heavy Sack, Safebox
--					/utt [name] [duration]	: Set the duration in seconds for the given container.
--			- Added more options to "/uespdump skills" to make it easier to dump partial skill logs for
--			  a certain class/race.
--			- The "/umi idcheck" was changed to do an iterative check instead of trying to do it all at
--			  once which resulted in a game crash. Now when run it will check 5000 items every 2 secs
--			  until finished. It cannot be stopped/interrupted once started.
--			- Added the "/umi quick [on/off]" option for mining items. Only mines/logs the normal v16
--			  version of each item.
--			- Fixed item links with no name showing (for Orsinium PTS).
--			- Added Orsinium mobs to ignore when logging.
--
--		- v0.41 - 2 December 2015
--			- Added some more Orsinium mobs to ignore when logging.
--			- Fixed logging of hireling mail items (properly logs hireling type).
--			- Added new/missing style icons.
--			- Removed the "Craft completed..." log message if no inspiration was gained.
--			- Tweaked inventory style/trait icon positions.
--			- Added the /uesplorebook (/ulb) command. This turns the various "Lorebook Learned"
--		      messages seen at the top of the window on/off as follows:
--					/uesplorebook        -- Display status
--					/uesplorebook help   -- Display basic help
--					/uesplorebook on     -- Display all lorebook messages (default)
--					/uesplorebook off    -- Only display Mages Guild related lorebook messages
--			- Fixed issue with message if you looted something at the same time as a group member.
--			- Zipped install file includes the root folder "uespLog".
--
--		- v0.50 - 17 December 2015
--			- REQUIRED UPDATE: uespLogMonitor updated to v0.20 to include the character build data
--			  upload and some critical related bug fixes.
--			- Fixed known/unknown display of the Mercenary style motifs. While the base game API is
--			  is still bugged for this style (it always says the style/chapter is unknown), uespLog
--			  now manually tracks the mercenary style. To setup simply visit a blacksmith and a 
--			  woodworking station for the add-on to automatically save your currently known mercenary
--			  chapters. This will be saved between sessions and updated automatically when you read
--			  a new mercenary chapter. If the status of a mercenary motif is uncertain no text/icon 
--			  will be displayed. 
--			- Added the /uespstyle command for displaying which chapters of a particular motif are
--			  known or unknown.
--					/uespstyle [stylename]     Shows which chapters you currently know or not
--					/uespstyle list            Shows all the style names accepted by the command
--
--			CHARACTER BUILD SAVING (needs testing)
--				A new feature which permits the saving of character build data (equipment, action bars
--				skills, champion points, buffs, etc...) and the uploading of the build data to the 
--				UESP.net website for display (http://www.uesp.net/wiki/Special:EsoBuildData).
--
--				For more detailed instructions see: http://www.uesp.net/wiki/UESPWiki:EsoCharData
--
--				To Save Characters:
--					Use the /uespsavebuild (or /usb) command in the game:
--						/usb [buildname]			   -- Saves the character data
--						/usb forcesave [buildname]     -- Saves data and ignores any errors
--						/usb status					   -- Shows how many saved builds are in the log
--						/usb clear					   -- Deletes all builds currently in the log
--
--				To Upload Characters:
--					On PC/Windows you can use the included uespLogMonitor program to automatically
--					upload the saved build data when the uespLog saved variable file is updated.
--
--					http://esolog.uesp.net/submit.php -- Uploads all logged and character data
--						from a saved variable file.
--
--					http://esobuilds.uesp.net/submit.php -- Uploads just the build data from a
--						saved variable file.
--
--				Submit bugs and feature requests to @Reorx in game or at http://www.uesp.net/wiki/UESPWiki_talk:EsoCharData		
--					
--		- v0.60 - 7 March 2016
-- 		    - REQUIRED UPDATE: uespLogMonitor updated to v0.30 to include the character data upload.
--			- Added the "/uespsavebuild screenshot"	(or "/usb ss") command to take a nicely
--			  framed screenshot of your character.
--			- The set count of equipped items is now saved with the "/uespsavebuild" command.
--			- Added the "/uespmineitems count" parameter.
--			- Added missing item level/subtype combinations for item mining.
--			- Fixed minor bug with "/uespreset all" and build data.
--			- Added the "/uespmineitems level" parameter.
--			- Added new Thieves Guild mobs to ignore list and removed "Mudcrab".
--			- Add support for logging "Thieves Trove" along with treasure timer.
--			- The new item tags are logged and shown in item info.
--			- Fixed bug in manual tracking of Ancient Orc and Mercenary styles (although they should now
--			  be tracked correctly in-game after the Thieves Guilds update).	
--			- Werewolf character state is properly saved when saving a build.
--			- Action bars are saved between sessions so you should no longer have to swap weapon bars each time
--			  you login to save a character build. Also fixed a bug which incorrectly considered action bar data
--			  to be not saved even though it was.
--			- The last food/drink consumed will be properly tracked for build/character data. Potions and other
--			  items consumed will be ignored.
--			- Added chat message when you take gold from mail attachments.
--			- Added the "/uesptrait" command to show known trait information:
--					/uesptrait       			Shows all traits for all crafting skills
--					/uesptrait blacksmith		Shows known traits for blacksmithing
--					/uesptrait clothier			Shows known traits for clothier
--					/uesptrait woodworking		Shows known traits for woodworking
--			  Note that traits shown as "[trait name]" in this command are being researched and are not
--			  considered as being "known".  Reworked the "/uespcount traits" command to just show the known 
--			  trait counts.
--			- Added the "/uespskillpoints" or "/usp" that shows the total number of skill points used and
--			  acquired on the character.
--			- Quest item links are now logged (this is currently the only way to get information about quest items).
--			- Removed the "Quest conversation updated", "Quest Advanced" and "Updated conversation" log messages from 
--     		  normal output.
--			- Changed default of data logging (/uesplog on/off) to false to prevent collection of data and increasing 
--			  the sized of the saved variable file for people not interested in collecting data. This only affects new
--			  installations. Use "/uesplog on" to ensure data collection is enabled.
--			- Fixed bug where menu settings were not being displayed the first time you open the add-on's settings menu.
--			- Handle eating food/drink from the quickslot bar.
--			- Beta: Show log message when creating a glass motif chapter.
--			- Resulting glyph levels will be shown in Enchanting Potency Runestone tooltips.
--
--		***BETA: Skill Coefficients***
--			- Added basic skill coefficient mining with "/uespskillcoef" or "/usc". The equation for the base skill tooltip is
--					BaseTooltip = A * Stat + B * Power + C
--			  where "Stat" is Magicka/Stamina and Power is Spell/Weapon Damage. The A/B/C parameters are not exposed
--			  in the game's API so must be calculated indirectly. The usual way to calculate these parameters
--			  is to record several different Tooltip/Stat/Power value combinations and do a "best fit" calculation.
--			  The "/uespskillcoef" command encapsulates all the math so all you have to do is provide several
--			  different Stat/Power combinations and "/uespskillcoef" will return the A/B/C parameters along with
--			  an "R" parameter (R-squared) indicating how accurate the fit is. An R value of "1" indicates a perfect
--			  fit with lower values indicates a worse fit.
--			   
--			  The /uespsavecoef (or /usc) command has the following parameters:
--						/usc save          	Save current skill data for the character. Note that only purchased skills
--											will be saved. All 3 versions of each skill will be saved (original and two morphs).
--											Note that logging out or "/reloadui" will clear the saved skill data.
--						/usc calc          	Calculate coefficients using previously saved skill data and store
--											coefficient data in the log. The "tempData" section of the saved
--											variables will also contain a CSV version of the coefficient data.
--						/usc coef [name]   	Shows the calculated coefficients for the given skill name.
--						/usc coef [id]     	Shows the calculated coefficients for the given skill ID.
--						/usc status        	Current status of saved skill data.
--						/usc clear         	Resets the saved skill data. Note that logging out or "/reloadui" will
--											also clear the saved skill data.
--						/usc savewyk [prefix] [start] [end]  
--											Saves skill data using Wykkyd's Outfitter add-on. 
--													ex: /usc savewyk Test 1 9
--											would try to load the sets 'Test1'...'Test9' and save the skill data
--											for each of them.
--						/usc stop           Stops a Wykkyd item set save in progress.
--
--			   The quality of the skill coefficients depend on the number and variety of stat/power combinations
--			   saved with "/usc save". A minimum of 3 saved sets are needed but in general you want many more.
--			   Ideally you want to vary all stats (Stamina, Magicka, Spell Damage, Weapon Damage) as much as
--			   possible to get more accurate results. To capture more data also vary things like armor types
--			   and weapon types as much as possible.
--
--			   The general procedure to accurately record/calculate skill coefficients is:
--					 1. Reset all champion points.
--					 2. Reset all skills.
--					 3. Purchase the base rank of all passives.
--					 4. Remove all skills from both ability bars.
--					 5. Equip/unequip items to change stats.
--					 6. Wait at least 5 seconds after changing equipment to let the game correctly update the skill values.
--					 7. Run "/usc save".
--					 8. Repeat steps 5-7 for 10 or more different stat combinations (magicka, stamina, spell/weapon damage).
--					 9. Run "/usc calc".
--					10. Run "/reloadui" or logout to update the saved variables.
--					11. Upload the saved variable file or copy/paste the coefficient data from the "tempData" section.
--	
--			  Uploaded and parsed skill coefficient data can be found at http://esolog.uesp.net/viewSkillCoef.php		
--			  or in the mined skills database at http://esoitem.uesp.net/viewlog.php?record=minedSkills   
--
--		***BETA: Offline Character Data***
--			- Expanding on the recent "Build Data" uespLog now has the option to automatically record more character
--			  data in order to view it offline. By default this feature is disabled. It can be enabled by the command:
--						/uespchardata on   		(or	/ucd on)
--			  When enabled character data will be saved whenever logging out, quitting or UI reloads.
--
--			  Character data uploading can be done the same way as build data:
--				1. On Windows use the included uespLogMonitor program to automatically upload data.
--				2. Use the http://esolog.uesp.net/submit.php form to manually upload all log, build, and character data.
--				3. Use the http://esochars.uesp.net/submit.php form to manually upload build and character data.
--
--			  Once uploaded the characters can be viewed at: http://esochars.uesp.net 
--
--						/ucd							  Short command name
--						/uespchardata [on/off]            Turn automatic saving on/off (default off)
--						/uespchardata save                Manually save the character data
--
--			  Data saved by the offline character data system includes:
--					* All skills/abilities/champion points and character stats
--					* All characters on account (you must login with each character to save it)
--					* Equipped items
--					* Character and bank inventory
--					* View combined account wide inventory of all characters + bank
--					* Crafting motifs learned
--					* Crafting traits researched
--					* Current status of crafting research (automatically updates research finish date/time)
--
--		- v0.61 -- 10 March 2016
--			- Adjusted log message when selling multiples of something.
--			- Char/build data tracks the 6 new styles.
--			- Added the "/uesptreasuretimer list" command to show timer durations as well as timers currently
--			  in progress. Timers shown in this list will persist through logins and /reloadui but the timer
--			  log notice will not.
--			- Fixed "/uesptreasuretimer thieves trove [duration]" to work.
--			- Updated some item style labels with new values.
--			- Fixed bug that prevented book data from being logged.
--			- CRITICAL: Fixed bug that was causing extreme lag when killing things with a Destruction Staff (and
--			  Two-Handed/Bow to a lesser extent). Root cause was due to the EVENT_ACTION_SLOT_UPDATED event being
--			  called 40-50 times at once when you kill a mob with a Destruction Staff equipped. The event was triggering 
--			  the saving of action bar data which caused the lag when done +40 times in the same frame. Action bar
--			  saving is now only done at most once every 5 seconds.
--
--		- v0.62 -- 12 March 2016
--			- Slash commands that don't start with "/uesp..." are checked to see if they exist before they are
--			  set. This prevents them from interfering with any other add-on that might happen to use them.
--			- Added the "/rl" chat command as a short form for "/reloadui".
--			- Added the "/afk", "/away" and "/back" chat commands for setting the player status (seen in guild).
--					/afk							Toggles AFK state on/off (away/online)
--					/afk [on/off]					Turns AFK state on and off (away/online)
--					/afk [away|online|dnd|offline] 	Sets player status to a specific state
--					/afk status						Shows the current player status
--					/away							Turns state to "Away"
--					/back							Turns state to "Online"
--			- Fixed logging of Thieves Troves.
--			- Added "/uespmineitems reloaddelay [seconds]" command for adjusting the minimum reload delay when
--			  auto mining items.
--			- Shortened the output from "/uespstyle". Added the "/uespstyle long [style]" command to format
--			  output in the long format.
--			- Another fix to try and eliminate the little bit of lag that some people experience when killing
--			  mobs with a Destruction Staff equipped.
--			
--		- v0.70 -- 31 May 2016
-- 		    - REQUIRED UPDATE: uespLogMonitor updated to v0.40 with updates to the character data upload.
--			- Fixed "Show Item Info" menu item when smithing an item.
--			- Updated clock/moon phases to be more accurate and match the lore date given by other addons.
--			- Improved skill data logging.
--			- Tweaked skill message when finding a Skyshard.
--			- Many changes to skill coefficients. The saved stat data is now saved account wide when logging out
--			  so you can save between multiple characters. Calculated coefficients are not saved.
--			- Fixed crash on OSx clients when catching a Wet Gunny Sack.
--			- Output in "/uespdebug extra" mode displayed in a different color (light gray).
--			- Added the "/uespdump skills missing [note]" command for dumping skills that are missing from
--			  the current PTS character templates.
--			- Added the "/uespshowcoor [on|off]" command to turn the map coordinate display on/off. Thanks to
--			  Ptits de Barbe for submitting this patch.
--			- Added the "/uespminecollect [note]" command for logging collectible data.
--			- Updated achievement data logging.
--			- Fixes for PTS update 10:
--				- Updated API to version 100015.
--				- Removed use of deleted API function GetStatSoftCap().
--				- Changed VR related items to CP.
--				- Fixed some minor looting display issues.
--				- Styles updated.
--				- Fix crash when mining items with subtype of 0 and some other values.
--				- Character data saves the craft bag inventory.
--
--			  Added several commands to /uespskillcoef (/usc):
--					/usc showdata [name/id]     Shows raw data for the particular skill
--					/usc showbadfit [R2]	    Shows all coefficients with an R2 value less than the given value.
--											    A default value of 0.99 is used if omitted.
--					/usc addskill [id]          Adds a specific skill to track when saving statistic data in future
--												calls to "/usc save". The character does not have to be able to 
--												learn or know the skill.
--					/usc addcharskills          Adds all skills available to the current character to be tracked
--												in future calls to "/usc save".
--					/usc addmissing             Adds all currently defined missing skills from PTS to be tracked in 
--												future calls to "/usc save".
--					/usc resetsaved             Clears all saved data points from "/usc save".
--					/uespreset skillcoef        Same as /usc reset.
--					/uespcount                  Shows the space taken by skill coefficients.
--
--			  As a result of these changes the method to compute skill coefficients on PTS has changed somewhat:
--					1. Reset all champion points and attributes
--					2. Run: /usc addmissing
--					3. Run: /usc addcharskills
--					4. Purchase one rank of all passives and repeat step 3 up to (MaxRank-1) of all passives
--						4a. If dumping skills run "/uespdump skills passive" in the previous step as well
--					5. Repeat steps 3-4 for all character classes
--					6. Add any missing skills (Emperor, etc...) using: /usc add [id]
--					7. On any v16 character run multiple "/usc save" as usual
--					8. Calc and save coefficients using: /usc calc
--					9. To reset saved parameters but keep the list of tracked skills use "/usc resetsaved"
--			  This should give you skill coefficients for all skills in one calculation.
--
--		- v0.80 -- 1 August 2016
--			- "/uespstyle" now works with the 3 new styles added in DB.
--			- "/usc addcharskills" now also adds CP passive abilities to coefficient tracking.
--			- Improving items will show the correct improved item link in the chat window now.
--			- Poison data is now collected when mining potion item data.
--			- Fixed saving of werewolf stat in character/build data.
--			- Added the "/uespcontloot [on|off]" command to autoloot items from containers. 
--			- Spell and Physical Penetration stats are added to the character and inventory window.
--			  Use "/uespcustomstat on" and reload the UI to take effect. The current list of custom stats are:
--					Spell and Physical Penetration
--					Spell and Weapon Critical Damage 
--						These values are calculated from scratch as the game gives no way to get their values.
--					Effective Spell and Weapon Power
--						These are custom stats meant to gauge your overall damage potential in terms of
--						Magicka/Stamina, Spell/Weapon Damage, Critical/Critical Damage, and Penetration.
--						It currently uses a target resistance of 18.2k with no critical resistance.
--			- Improved the display of the startup message.
--			- Changed how some of the more useful chat messages are output and added the "/uespmsg" command 
--			  to control their display.
--						/uespmsg                   Shows the current stats
--						/uespmsg [on|off]          Turns all messages on/off
--						/uespmsg loot [on|off]     Turns loot related messages on/off
--						/uespmsg npc [on|off]      Turns NPC related messages on/off
--						/uespmsg quest [on|off]    Turns quest related messages on/off
--						/uespmsg other [on|off]    Turns all other messages on/off
--            Now "/uespdebug" only controls the display of less useful debug related messages. Initially all
--			  new messages are off unless you have "/uespdebug on" set in which case they are initially turned on.
--			- A little better support for other languages. If you are using a non-English version and are
--			  having problems or wish to help test things let me know.
--
--			- Shadows of the Hist Updates
--				- API updated to 100016.
--				- Added the 5 new styles (Dark Brotherhood, Akatosh, Dro-m'Artha, Minotaur, Grim Arlequin, Hollowjack).
--
--		- v0.90 -- 5 October 2016
--				- Hireling logged data now includes the crafting and hireling passive levels.
--				- Added the "/uespmsg inspiration [on|off]" command.
--				- Crafting writ footlockers now log the character's crafting level.
--				- Fixed logged dye data from achievements not matching the achievement. Also all data within
--				  an achievement line is now logged.
--				- Dye stamp data for item links is now logged.
--				- Fixed the Grim Harlequin style ID.
--			One Tamriel Changes (Update 12)
--				- Increased API to 100017.
--				- Increased item mining max ID to 130000.
--				- Fixed a bug related to the new stat comparison feature on the inventory menu. If you still run into
--				  issues you can disable custom stats with the "/uespcustomstats off" command.
--				- Shortened the labels for custom stats to make room for the stat comparison feature. Note that 
--				  comparison of custom stats is not yet available.
--				- Added the "/uespcustomstats custom" option. This displays the change in stat value for the new
--				  statistic comparison feature in the inventory stats window.
--				- Added the 3 new styles (Celestial, Yokudan, Draugr).
--
--		- v1.00 -- 6 February 2017
--				- Mined item data for recipes now includes the information needed to duplicate the in-game
--				  tool-tip displayed for recipes.
--				- Fixed the stacking of Major Force in the Critical Damage stat display.
--				- Fixed the display of a known recipes that shows as unknown in your inventory (Ghastly Eye-Bowl Recipe).
--				- Fixed the custom Effective Weapon/Spell Power stats for characters not at max level.
--				- Fixed item style display toggle.
--				- Fix effective spell/weapon power calculation.
--				- A warning is displayed in the chat window if you use an unknown slash command.
--				- Added some missing/extra style names for the "/uespstyle" command.
--				- Added 12 missing styles to the saved character data.
--				- Fixed bug where uespLog thought you ate/drank something you actually didn't.
--				- Fixed the item link tooltip "Show Item Info" to work with other addons that modify the same context
--				  menu (like MasterMerchant).
--				- Added the "/uespstyle summary" and "/uespstyle all" commands to show a summary of all styles known.
--				- Added the 2 new styles from the New Life Festival (Skinchanger and Stalhrim Frostcaster).
--				- Added the 3 crown store merchants to the NPC ignore list.
--				- Added the "Copy Item Link" context menu to item tooltips. This popups up a simple dialog that
--				  lets you press CTRL+C to quickly copy the item link. Press ESC or click anywhere to close the dialog.
--			- Added the /uespkilldata command to tracking basic kill statistics of NPCs (number and total health).
--			  Data is tracked per character and is saved between sessions.
--					/uespkilldata on/off				Turns the feature on and off (default is off).
--					/uespkilldata reset					Clears the current data.
--					/uespkilldata show					Lists all the current kill data.
--					/ukd                                Short command 
--			- Added the /uesptrackloot command to track loot received. Data is tracked per character and is
--			  saved between sessions. Gold, experience, Tel Var, and Alliance Points are also tracked. The
--			  item value shown is the MasterMerchant average value if that add-on is installed and has data
--			  for that item. Otherwise the item's gold value is used.
--					/uesptrackloot on/off				Turns loot tracking on/off.
--					/uesptrackloot show					Displays all items looted.
--					/uesptrackloot show [name]			Show all looted items matching the given name.
--					/uesptrackloot sources				Show all sources of loot.
--					/uesptrackloot sources [name]		Show all sources of loot matching the given name.
--					/uesptrackloot reset				Clear all loot tracking data.
--					/utl 								Short command
--			- Removed old code for manually monitoring the Mercenary and Ancient Orc styles.
--			- Added logging when pickpocketing for the NPC thieving class and other data.
--
--			Update 13 Changes
--				- API updated to 100018.
--				- Added the new special item type to logged item data.
--				- Added ingredient quantities to logged recipe data.
--				- Added furniture category data to logged item data.
--				- Updated item logging with change to multiple tradeskill requirements.
--				- Fixed UI error with autolooting containers enabled. Note a small change in the behaviour of autolooting
--				  containers when your inventory is full. It will autoloot as many items as your inventory can hold but
--				  will no longer display the open container showing remaining items.
--				- Fixed known/unknown display of recipes.
--				- Added the 4 new styles: Silken Ring, Mazzatun, Ra Gada, and Ebony
--
--			- Guild sales data tracking and price display. A new feature in testing since v1.00 which logs guild
--			  sales data from several sources including:
--					- Logs sales from your guild history
--					- Logs items you list
--					- Logs item searches from all guild traders
--					- Manually scan of listings in the current guild store with "/uespsales scan"
--			  All uploaded sales data can be viewed at http://esosales.uesp.net/ . Average price data is computed
--			  using both the listed items and sold items for potentially greater accuracy in the price calculation.
--
--			  Note that the addon includes prices for the PC-NA server at the time of the add-ons release. For 
--			  updated prices and other servers you can download an updated price file (uespSalesPrices.lua) at:
--
--					http://esosales.uesp.net/salesPrices.shtml
--
--			  Sales data logging and price display can be controlled with the "/uespsales" command:
--					/uespsales [on|off]            Turn logging of sales data on/off.
--					/uespsales prices [on|off]     Enables/disables all UESP price diplays.
--					/uespsales tooltip [on|off]    Turns price item tooltip display on/off.
--					/uespsales saletype both       Uses both listed and sold data when displaying prices.
--					/uespsales saletype list       Uses only listed data when displaying prices.
--					/uespsales saletype sold       Uses only sold data when displaying prices.
--					/uespsales scan                Scans all guild store listings.
--					/uespsales scan [page]         Scans the current guild store listing at the given page.
--					/uespsales stop                Stops the current listing scan.
--					/uespsales resetall            Reset the sales and listing scan timestamps.
--					/uespsales resetsold           Reset the sales history scan timestamps for  all your guilds.
--					/uespsales resetlist all       Reset the listing timestamps for all guilds.
--					/uespsales resetlist current   Reset the listing timestamps for the current guild trader.
--					/uespsales resetlist [name]    Reset the listing timestamps for that guild.
--					/uespsales deal [uesp|mm|none] Sets how item deals are displayed in guild trader searches.
--
--			  When doing a manual scan of guild listings you need to be at a guild trader kiosk or bank screen.
--			  When at a guild store bank it will scan all guilds you are currently in. A full scan can take 
-- 			  up to 10 minutes depending on how many items are in the guild store. You have to remain on the 
--			  trader during this time and you cannot perform any searches yourself as this will interfere with
--			  automatic scan. You can stop a listing scan with "/uespsales stop" or by exiting the guild trader
--			  interface at anytime.
--
--			  Once a guild scan has been completed then subsequent scans will only need to scan any new items
--			  listed since the last scan. This applies to both guild listings and guild sale histories. You
--			  can reset these with the "/uespsales resetlist" and "/uespsales resetsold" commands but the
--			  next scans will then require a longer complete scan. Daily updated versions of this file can
--			  be downloaded from  http://esosales.uesp.net/ . If you don't use the UESP price data at all you
--			  can delete everything in this file with any text editor to save a little bit of memory.
--
--			  If sales price logging is enabled (/uespsales on) then two buttons in the bottom-left corner of the
--			  guild trader listing window will be added that perform the equivalent of "/uespsales scan" and 
--			  "/uespsales resetlist current".
--
--			  Collected price data is included in the "uespSalesPrices.lua" file. Average price data can be
--			  viewed in item tooltips if you turn them on with "/uespsales prices on" and "/uespsales tooltip on",
--			  much in the same manner as with the MasterMerchant add-on. 
--
-- 			  You can control which type of sales data is used for the average price with the commands:
--					/uespsales saletype both       Uses both listed and sold price data.
--					/uespsales saletype list       Uses only listed price data.
--					/uespsales saletype sold       Uses only sold price data.
--
--			  Using only sold data would be the same as how the MasterMerchant add-on works. Using only the listed
--			  data would be the same as how the TamrielTraderCentre add-on works. Using both gets you the best
--			  of both worlds. 
--
--			  If you have MasterMerchant and AwesomeGuildStore installed you can use "/uespsales deal" to change
--			  how the item deal label is calculated and displayed:
--
--					/uespsales deal mm      Use the default MM price data and deal calculation.
--					/uespsales deal uesp    Use the UESP price data and deal calculation.
--
--			  When switching between types you must close and reopen any existing guild trader searches in order
--			  to update the data. Currently item deals are only displayed if MM and AGS are both installed.
--			- Fishing notifications (turn on with /uespfish on)
--			- Daily quest tracking (/uespdaily)
--			- Added the /uesptrackstat command for tracking changes to Health/Magicka/Stamina/Ultimate. You
--			  can enable tracking of one or more stats and any change will be displayed in the chat window
--			  along with a game time reference. Warning that this command results in a lot of messages as you
--			  might expect.
--					/uesptrackstat                        Shows command help and current status of tracking.
--					/uesptrackstat health[on/off]         Turns Health tracking on/off.
--					/uesptrackstat magicka [on/off]       Turns Magicka tracking on/off.
--					/uesptrackstat stamina [on/off]       Turns Stamina tracking on/off.
--					/uesptrackstat ultimate [on/off]      Turns Ultimate tracking on/off.
--					/uesptrackstat weapondamage [on/off]  Turns Weapon Damage tracking on/off.
--					/uesptrackstat spelldamage [on/off]	  Turns Spell Damage tracking on/off.
--					/uesptrackstat all					  Start tracking all stats.
--					/uesptrackstat none					  Turns off all tracking.
--					/uesptrackstat resettime			  Resets the game time display to 0.
--
--		- v1.01 -- 4 March 2017
--			- Fixed motif unknown/known display.
--			- Add recipe known display to tooltips.
--			- Update skill coefficients for a few skills that had incorrect coefficient types.
--			- Writ vouchers added to character data export.
--			- Added the /offline and /online commands (short for "/afk offline" and "/afk online").
--			- Added the "/uespmineitems itemtype" parameter to permit mining of specific item types. Tweaked output of
--			  the item mining to better indicate how many valid items have been mined.
--			- Changed the craft style, trait, recipe/motif, and ingredient display toggles to each individually control
--			  whether they are displayed in inventory rows and/or item tooltips.
--			- Fixed style Grim Harlequin from incorrectly showing as unknown in some cases.
--			- Mostly fixed the error that occasionally would stop a guild listing scan before it was actually finished.
--			  It still rarely occurs but much less often than previously.
--			- "/uespcount recipes" now shows counts per recipe categories.
--
--		- v1.10 -- 22 May 2017
-- 			- uespLogMonitor updated to 0.50 with several minor bug fixes and performance improvements.
--			- Added the "/uespcraft alchemy on|off" command which turns on tooltips when in the alchemy crafting window.
--			- Fixed UESP sales price not appearing in tooltips from top item rows.
--			- Fixed price lookups for master writs and crafted potions.
--			- Fixed item mining with no item type set.
--			- Stopping a guild listing scan in progress with "/uespsales stop" now works correctly.
--			- Removed the "No items crafted." message.
--			- Save both overload and werewolf ability bars for build and character data. Note that you have to activate
--			  the ability bar for it to be updated. Previously it would only save these bars if you zoned, logged out,
--			  or reloaded the UI while they were active. Also a Sorcerer Werewolf would only save the last extra bar
--			  used and not both of them.
--			- Tweaked the position of known/unknown and trait icons in the guild trader list.
--			- Added the "Goto UESP Sales..." right-click menu option which opens a browser to the UESP sales page
--			  for that item link (you are prompted to open a browser).
--			- Added several new commands to "/uespresearch":
--					/uespresearch help         Shows command details
--					/uespresearch includesets  [on|off]
--							When this is off then set items do not appear in the smithing research selection list.
--					/uespresearch maxquality   [0-5]
--							When set to a value from 1-5 then items with a quality higher than this value do
--							not appear in the smithing research selection list. Set to 0 to disable.
--			- Added the /uesphome command (and /home if not already used) which teleports you to your primary residence.
--			- Added the /uesphireling (or /uesphire) which shows you the remaining time to receive your next hireling
--			  mails. Note that you need to receive a hireling mail after install this addon in order to know the
--			  time for the next mail.
--			- Added the "/uesprawprice" command that outputs the market value (UESP or MasterMerchant) of all smithing 
--			  raw materials along with the market value of the refined material including all temper materials expected
--			  to be returned. The output is sorted from lowest net price to highest.
--						/uesprawprice          -- Show all prices
--						/uesprawprice [name]   -- Show all prices matching "name"
--			- Item values used in /uesprawprice and /uesptrackloot now use the UESP value if it exists. Otherwise it
--			  uses the MasterMerchant item value if present or, if not, the default game item value.
--			- Changed the base "/uesptrackloot" command to show loot statistics instead of the help text.
--			- Changed the base "/uespkilldata" command to show kill statistics instead of the help text.
--			- Added the "/uespmasterpotion" command. Use this command when you have an Alchemy Master Writ quest
--			  in progress while at an Alchemy station in order to setup your solvent and reagents automatically.
--					/uespmasterpotion help       Show command help.
--					/uespmasterpotion            Use the first potion combination found.
--					/uespmasterpotion [#]        Use the specified potion combination (1-N).
--			  This command needs more testing to ensure it works for all alchemy master writs.
--			- The "/uespspeed" command no longer outputs 0 speed values to the chat window.
--			- Increased item mining max ID to 150000.
--			- Fixed mining items of all types.
--			- Game time returned by /uesptime incremented by one game day to match time used by the Clock 0.7.7 addon.
--			- "/uespstyle" now shows the full in-game style name for valid styles.
--			- Chests, Safeboxes and Thieves Troves now display and log the lock level.
--		Update 14 Morrowind Changes:
--			- Expanded bank related functions to include the ESO subscriber bag.
--			- Added the Ashlander, Buoyant Armiger, Morag Tong, and Militant Ordinator styles.
--
--		- v1.11 -- 25 May 2017
--			- Achievement data is now saved in the normal log data section instead of a the custom "achievement" data section.
--			- Skill point message received when levelling up should be correct.
--			- Missing sales data won't trigger a Lua error.
--			- Added the uespSalesPrices.lua file back into the installation to prevent issues with some installations. This is
--			  the PC-NA prices from this release data so be to sure to visit http://esosales.uesp.net/salesPrices.shtml and
--			  download the latest file for your server to get the most accurate sales prices. 
--
--		- v1.20 -- 14 Aug 2017
--			- Improved note/book message to include collection categories. 
--			- When reading a lore book only one console message is output.
--			- Fixed deal type display in guild stores that was incorrect for some items.
--			- When posting items you can use the MasterMerchant or UESP (default) prices by using the commands:
--					/uespsales postprice uesp
--					/uespsales postprice mm
--			- Listing deal display and post pricing now works whether MasterMerchant is installed or not. Basic price display
--			  should now be working with MasterMerchant not present although more advanced features/options available with MM 
--			  will not be available.
--			- Added the Telvanni, Hlaalu and Redoran styles to inventory display.
--			- Fixed style name display to use the new built-in API function for getting the style name.
--			- Fixed PVP message output. Properly displays messages for captured and keeps under attack. No longer displays
--			  messages in battlegrounds for more events.
--			- Modified the effective power stats to include Mighty/Elemental Expert and basic forms of damage done modifiers
--			  in order to match the online builder values.
--			- Added the "/uesppvpqueue" command which queues you for a specific PVP campaign by name or ID. You can queue for
--			  any valid campaign that you are able to enter and it bypasses the home/guest check (unless you enter your home
--			  campaign you will act as a guest).
--						/uesppvpqueue [name]        Queue using the campaign name
--						/uesppvpqueue [number]      Queue using the campaign ID (1-87)
--						/uesppvpqueue home          Queue for your assigned home campaign
--						/uesppvpqueue guest         Queue for your assigned guest campaign
--						/uesppvpqueue list          List all open campaigns
--						/uesppvpqueue listall       List all known campaigns
--			- Character data now saves banked writ vouchers and AP.
--			- Updated sales prices with latest from PC-NA (remember to download PC-EU prices manually if needed).
--
--		- v1.30 -- 23 Oct 2017 (Clockwork City)
--			- Fixed the /uespstyle output and saved character data for several styles (Morag Tong, Armiger, Redoran, Telvanni, Hlaalu)
--			  that was not correct.
--			- The /uesppvpqueue command no longer works to queue for a campaign that is not your home or guest due to a 
-- 			  change in the game's API.
--			- The "/uesppvpqueue list" command displays a message if campaign data has not yet been 
--			- Fixed /uespstyle to work with the new style API functions.
--			- Fixed reporting of Alliance Points carried by character in saved data.
--			- Updated API to 100021.
--			- Added the Bloodforge, Dreadhorn, Apostle, and Ebonshadow styles.
--			- The new patch displays Ornate, Intricate, and research icons in inventory lists by default now. The uespLog equivalent
--			  features can be disabled by "/uespcraft" command or in the settings menu.
--			- Number of Transmute Crystal saved for offline character data.
--			- Fixed error message if using the Mailr addon.
--			- Hireling mail timers are now ignored if the character has not purchased the relevant passive.
--			- Fixed skill coefficient calculations for the Malevolent Offering, Dragonkngith Standard, and Healing Seed skills 
--			  and their morphs.
--			- Added messages for received/losing writ vouchers and transmute stones (classed as "other messages" in settings).
--			- Fixed logging of Blacksmithing raw material nodes (not confirmed to work in non-english clients).
-- 			- Fixed the custom stat display settings for new installation.
--			- Added setting for automatic hireling mail looting to the UI menu (/uesphireling autoloot).
--			- Removed the ornate/intricate text on item tooltips.
--			- Added the "/uespcraft traiticon on/off" option which controls the display of ornate and intricate trait icons in
--			  inventory displays. By default this is off as the base game API now should display these.
--			- Added the "Queue Writ Potion" right-click context menu item for Alchemy Master Writ items in your inventory. When
--			  this is choosen the writ is added to a list of potions/poisons to create. When at an Alchemy Station you can use
--			  the following commands to setup a potion from this list:
--					/uespmasterpotion queue		Sets up the top potion/poison in queue to be created
--					/uespmasterpotion popqueue	Sets up the top potion/poison in queue to be created and removes it from the queue
--			  This queue is *not* saved to the character's saved variable data and it reset on load or UI reload.
--			- Updated sales prices with latest from PC-NA (remember to download PC-EU prices manually if needed).
--
--		- v1.31 -- 23 Oct 2017
--			- Fixed Lua error when purchasing something from a guild store.
--			- Fixed the position of the scan/reset sales button when Awesome Guild Store is not installed.
--
--		- v1.40 -- 12 Feb 2018
--			- Added NPCs to ignore from Clockwork City.
--			- Fixed dumping of global data.
--			- Added the "Keep Chat Open" option. Defaults to off but when turned on it will keep the chat window open
--			  in certain cases where it is closed by default (trader, dye station, crown store, etc...).
--			- Added the 4 new motifs in CWC to saved character data.
--			- /uespskillpoints now ignores "free" passive skills in the total count.
--			- Added most daily quests from the last several expansions.
--			- Updated the LibAddOnMenu and LibStub libraries. This fixes a UI error bug.
--			- Added '/uespstyles' to be the same as '/uespstyle'.
--			- Added '/uespstyle known' and '/uespstyle unknown' commands to list known/unknown styles.
--			- The '/uespstyle' command no longer displays the Universal style in summary outputs.
--			- '/uespstyle' now accepts any short abbreviation of the style name. For example '/uespstyle x' would show the
--			  known pieces for the Xivkyn style. 
--			- Added the '/uespstyle master' or '/uespstyle writ' commands which display a summary of all styles that
--			  contribute to your chances of receiving a master writ.
--			- Character data saves motif data for all game styles by default.
--			- Output for '/uespstyle list' shows just the full names for all valid styles in the game.
--			- Added the '/uespsales bank', '/uespsales craftbag' and '/uespsales inventory' which display the estimated
--			  value of all sellable items with valid prices in the given bags.
--			- '/uespskillpoints' now shows your total number of skills points.
--			- Added a few more "free" skills that don't contribute to your total skill point count with '/uespskillpoints'.
--			- Fixed '/uespskillpoints' that incorrectly didn't count the first morph of skills as a point.
--			- Added the '/uespskillpoints debug' that outputs skill point information used to generate the count.
--			- Fixed the PC-NA sales price file data file which had become larger than allowed in Lua. Changed the way
--			  the sales data is initialized to get around that limit.
--			- Fixed guild listed items scan that would incorrectly not scan new items (seems to be due to a bug in the API).
--			- Tweaked output of guild listed items scan to show how long it has been since the last scan.
--
--		  Dragon Bones Related Changes
--			- Fixed bug with custom stat display and setting it via the UI menu.
--			- Added house storage to character data.
--			- Added the Worm Cult style.
--			- '/uespskillpoints' only counts skills in discovered skill lines. This prevents issues with some racial passives
--			  that are shared between 2 races that don't properly reset to 0 in this update.
--
--		- v1.41 -- 16 March 2018
--			- Fixed missing preview option in crown store.
--			- Removed notification of rising skill rank in undiscovered racial lines.
--
--		- v1.50 -- 21 May 2018
--			- Added journal quests, completed quests, books, Collectibles, and guilds to saved character data.
--			- Added the command "/uespchardata extended [on/off]". This is enabled by default and permits the saving
--			  of book, collectible, recipe, quest, and achievement character data. Turning it off can reduce the size of
--			  the saved character data (around 400k per character).
--			- /uespskillpoints now outputs the number of skyshards found and in total. 
--			- Added overall found/total skyshards to saved character data.
--			- Fixed the used/total skill points as saved in character data.
--			- Removed the "/uespchardata password ..." commands as they are no longer needed.
--			- Added "/uespbuild" command as an alias for "/uespsavebuild"
--			- Updated uespLogMonitor to v0.60 to include support for automatically uploading build/character screenshots
--			  as well as a crash bug when it encounters certain data.
--			- Transmute Stones gained/lost are now displayed in the chat log.
--			- Writ Vouchers and Transmute stones are now logged with /uesptrackloot.
--			- Buying chat logs now display the correct currency type.
--			- Fixed house storage character data when you logged in and didn't access the storage.
--			- Looted master writs will display the number of writ vouchers after the item link in chat like:
--					You looted [Sealed Blacksmithing Writ] (24 writ vouchers) from footlocker.
--			- The "/uesprawprice" command now works regardless of if MasterMerchant is installed. Either MM or UESP
--			  sales prices need to be enabled for it to work.
--			- Fixed the known style display for a few Worm Cult motifs.
--			- Moved the uespSalesPrices.lua file which contains all the data for displaying item sales
--			  prices from esosales.uesp.net to its own add-on "UespLogSalesPrices". This lets you turn on/off the
--			  loading of sales data on a per-character basis.
--			- Added the "/uespsales writworthy [on|off]" which enables Writ Worthy to use UESP price data for writ
--			  value estimates. Default is off. Note that the Writ Worthy has to be loaded and UESP price data has to
--			  to be turned on (/uespsales prices on).
--			- Removed Features (these were in testing and not completely working):
--				- /uespmasterpotion command (use the Writ Worthy add-on)
--				- /uesplorebook command (API was redone in update 18)
--			- Redid the item tooltips for UESP sales prices so that they'll always show up correctly.
--			- Added the /uespmasterwrit (or /umw) command which displays an estimate for your chance to receive a
--			  master writ for each crafting skill.
--					/uespmasterwrit        Show chances
--					/uespmasterwrit help   Help text
--					/uespmasterwrit prov   Show recipes contributing to master writ chance
--					/uespmasterwrit motif  Show motifs contributing to master writ chance
--			- Stopped "/uespreset all" from preventing some data from being saved until you reload the UI/game.
--			- Added known/unknown display text/icons for Runeboxes. Controlled by the trait display setting.
--			- Crafting messages in the chat log should now always display the correct result item link. This includes
--			  when using the Dolgubons and WritWorthy addons.
--			- Added the "/uespstyle material" command which shows all styles including material link and current
--			  count of that material.
--
--		Summerset Related Changes (Update 18):
--			- Added style icons for the Fang Lair, Scalecaller, Psijic Order, Sapiarch and Pyandonean styles.
--			- Added Jewelry Crafting to all crafting related commands and features:
--				- Saved character data.
--				- /uespmaster writ
--				- /uesptrait
--				- /uespresearchinfo
--				- Known/unknown trait tooltips
--				- Known/unknown inventory row icons
--				- Jewelry writ crate logging.
--				- Daily writ tracking.
--
--		- v1.51 -- 21 May 2018
--			- Prevented startup error message if LibLazyCrafting was not found.
--			- Updated price data with latest from PC-NA.
--
--		- v1.52 -- 5 June 2018
--			- Fixed a few skill coefficient data issues.
--			- Added "Mud Hopper" as an ignored NPC.
--			- Added "Salamander Variant" as an ignored NPC.
--			- Added "Lesser Sea Adder" as an ignored NPC.
--			- Added "Fledgeling Gryphon" as an ignored NPC.
--			- Added the "/uespmarket" command which lets you turn off the new market announcement window that
--			  is shown when you login.
--					/uespmarket on      Window is shown
--					/uespmarket off     Window is not shown
--			- Disabled the warning when the log gets too large (no more chance of file corruption).
--			- Fixed the API version in the uespLogSalesPrices add-on.
--			- Added Werewolf Transformation as a "free" skill when counting skill points.
--			- Fixed a "Protected Function" error that would occur when using "E" to deposit/withdraw items.
--			- Fixed the missing Ancient Elf style icon.
--
--		- v1.60 -- 13 Aug 2018
--			- The market announcement window will only be hidden in the first 30 seconds of login time. After that
--			  time it can be displayed normally through the main menu selection.
--			- Reduced the number of quest condition messages you see in chat by not displaying hidden conditions or
--			  condition counters that haven't changed.
--			- Effective spell/weapon damage and spell/weapon critical damage are saved as character stats.
--			- Updated API version for Wolfhunter DLC.
--
--		- v1.61 -- 14 August 2018
--			- Added the Welkynar style.
--			- Added missing Runebox IDs from new content (for known/unknown display).
--			- Fixed error on call to GetJournalQuestConditionType() with incorrect parameter type.
--			- Removed the /uespmarket command which was causing crashes when purchasing skills (use the "No, Thank You!" addon instead).
--
--		- v1.70 -- 22 Oct 2018
--			- Fixed skill coefficient calculation for Werewolf ultimates.
--			- Added Stonefire Scamp and Soul-Shriven skin for runebox known/unknown tooltips.
--			- Added all current style pages to known/unknown tooltips.
--			- Fixed issue with LoreBooks causing GetLoreCollectionInfo() to return nil values causing crash.
--		Murkmire Related:
--			- Added the 4 new styles: Huntsman, Elder Argonian, Silver Dawn, Dead-Water
--
--		- v1.80 -- 25 Feb 2019
--			- Fixed several skill coefficient calculations.
--			- Added the Werewolf Devour passive to the list of free skills.
--			- The Dremora style now works with /uespstyle.
--			- Added the Honor Guard style.
--			- Added missing custom icons for some Murkmire styles.
--			- Fixed skill coefficient calculation for damage shield tooltips that cap with health. Note that in order for the skill
--		      coefficient of these tooltips to be calculated you need to save at least 2 values below the cap. Tooltip values at the 
--			  cap are ignored in order to get a valid linear best fit.
--			- Fixed the sales price column display in the new guild store UI.
--			- Fixed the copy item link dialog to automatically select all text initially.
--			- Updated sales price to most recent PC-NA version.
--
--		- v1.90 -- 20 May 2019
--			- Fixed use of removed API function in /uespminecollect.
--			- Updated list of rune box IDs.
--			- uespLogMonitor: Updated to v0.61 to fix uploading builds from multiple accounts.
--			- Fixed build/character uploading active skills as all rank 1.
--			- Fixed display of sales price deal margins in guild stores.
--			- Re-added the "Scan Sales" and "Reset Sales" button at the bottom of the new guild store window.
--			- Sales item list will update while doing a scan. Note that if AwesomeGuildStore is installed the item list will not be
--			  updated during the scan (sales data is still being collected however).
--			- Sale item data saved from guild stores now includes the new uniqueId which prevents any duplicates from being saved.
--			- Fixed skill coefficient descriptions missing description header.
--			- Skill coefficients are now saved/added asynchronously to prevent a data corruption bug. While skill data is being saved
--			  you should not change equipment/skills to prevent the skill data from changing mid-save.
--			- Removed usage of Wykkd outfitter in skill coefficient code.
--			- Item mining is done a little more asynchronously now in order to prevent some data corruption issues.
--			- Fixed rare bug with effective weapon/spell power calculation can result in NANs causing issue with saved variable loading.
--			- Fixed incorrect loot source that occurs in certain situations (mainly when looted a chest/sack and targetting something else).
--			- Messages about finding treasures and fishing holes should be a little less spammy.
--			- Added a "looting" message when you purchase an item from a guild store.
--		Elsweyr (Update 22)
--			- Fixed recognizing a valid item link.
--			- Fixed several incorrect/updated skill coefficient types.
--			- Added the new styles: Coldsnap, Meridian, Anequina, Pellitine.
--
--		-- v1.91 -- 24 May 2019
--			- Updated runebox data.
--			- Fixed some skill coefficient data.
--			- Fixed incorrect directory structure in release ZIP.
--
--		-- v2.00 -- 12 August 2019
--			- Checks for existance of RequestGuildHistoryCategoryNewest and RequestGuildHistoryCategoryOlder functions before using them
--			  for guild history scans.
--          - Updated API version for Scalebreaker.
--	
--		-- v2.10 -- 21 October 2019
--			- Fixed skill coefficients for a bunch of skills.
--			- Fixed scanning of guild sales history.
--			- Added reaction to NPC logged data.
--			- /uespmakelink will default to a CP160 gold item by default.
--			- Fixed icon for the Pellitine style.
--			- Added new styles: Sunspire, Dragonguard, Stag's of Zen, Moongrave Fane
--
--		-- v2.20 -- 24 February 2020
--			- Updated runebox data.
--			- Updated game time clock to match other clock addons (lost one day and shifted day of the week by one).
--			- Logs extra data for quest gold and experience rewards.
--			- Updated sales data with latest NA prices.
--
--		-- v2.21 -- 4 May 2020
--			- Fixed the map coordinates being displayed after the map window was closed.
--			- Improved logging of quest data. Among other things, quest IDs are logged when the quest is removed in an 
--			  attempt to better identify quests with identical names.
--			- Warning is displayed for /uespmineitems and /uespdump if logging is disabled.
--			- Fixed style entry for Moongrave Fane.
--			- Added inventory icon for the unique style.
--
--		-- v2.22 -- 6 May 2020
--			- Reverted change to outputting long strings to log (strings longer than 2000 bytes still output nil).
--
--		-- v2.30 -- 26 May 2020 (Greymoor fixes)
--			- Increased max potion effect to 32 when mining potion item data.
--			- Increased maximum item ID for auto-mining to 180,000.
--			- Added new data when logging skills (toggle and cost over time).
--			- Added style entries for Shield of Senchal, Blackreach Vanguard, Ancestral High Elf, Ancestral Orc,
--			  Ancestral Nord, Icreach Coven, and Pyre Watch.
--			- Updated collectible runebox IDs.
--			- Logging of Mythic item quality data is now supported (GetItemLinkDisplayQuality()).
--	
--		-- v2.31 - 3 July 2020 
--			- Removed the old built-in LibAddonMenu to prevent conflicts with global version.
--			- Fixed display of (x0) when looting leads.
--			- Fixed loot source display when looting from container in inventory.
--			- Items looted from antiquity dig sites are now logged and displayed in chat (if loot messages are on).
--			- Added a few new critters to the ignored NPC list.
--			- Removed duplicate message when receiving items from Remains-Silent.
--			- Sales/tooltip functions are only overridden if sales prices are set to "ON". Requires a UI reload to update.
--			- Fixed error message when purchasing items from a guild store.
--
--		-- v2.40 -- 24 August 2020 (Stonethorn release)
--			- Updated API versions
--
--		-- v2.41 -- 31 August 2020
--			- Added Sea Giant style.
--			- Fixed a bug that prevented listing items in guild stores in some cases.
--
--		-- v2.50 -- 2 November 2020 (Markarth)
--			- Updated runebox data.
--			- Added more zone and POI logging.
--			- Location logging now includes the world coordinates from GetUnitRawWorldPosition().
--
--		-- v2.60 -- 8 March 2021 (Flames of Ambition)
--			- Fixed character/build data recognizing vampirism.
--			- Increased max skill/item ID when mining to 200,000.
--			- Character data saves the new advanced stats and champion point data.
--			- "/uespdump cp" now saves the new champion point data.
--			- Fixed error with initializing custom character stats.
--			- Spell/Weapon Critical Damage custom stats are modified by the new CP.
--			- Added new motifs/styles: Greymoore, Thorn Legion, Hazardous Alchemy, Ancestral Reach, 
--			  Nighthollow, Arkthzand Armory, and Wayward Guardian.
--			- API updated to 100034.
--			- Updated runebox data.
--
--


--	GLOBAL .
uespLog = uespLog or {}

uespLog.version = "2.60"
uespLog.releaseDate = "8 March 2021"
uespLog.DATA_VERSION = 3

	-- Saved strings cannot exceed 1999 bytes in length (nil is output corrupting the log file)
uespLog.MAX_LOGSTRING_LENGTH = 1900

uespLog.TAB_CHARACTER = "\t"
uespLog.MIN_TARGET_CHANGE_TIMEMS = 2000

uespLog.currentHarvestTarget = nil
uespLog.lastHarvestTarget = { }

uespLog.startGameTime = GetGameTimeMilliseconds()
uespLog.startTimeStamp = GetTimeStamp()
uespLog.currentXp = GetUnitXP('player')

uespLog.lastMailItems = { }
uespLog.lastMailId = 0
uespLog.lastMailGold = 0
uespLog.lastMailCOD = 0

uespLog.lastPlayerHP = -1
uespLog.lastPlayerMG = -1
uespLog.lastPlayerST = -1
uespLog.lastPlayerUT = -1

uespLog.printDumpObject = false
uespLog.logDumpObject = true
uespLog.dumpIterateUserTable = true
uespLog.dumpIterateNextIndex = nil
uespLog.dumpIterateObject = nil
uespLog.dumpIterateStatus = 0
uespLog.dumpIterateParentName = ""
uespLog.dumpIterateMaxLevel = 3
uespLog.dumpIterateCurrentLevel = 0
uespLog.DUMP_ITERATE_TIMERDELAY = 100
uespLog.DUMP_ITERATE_LOOPCOUNT = 1000
uespLog.dumpIterateEnabled = false
uespLog.dumpMetaTable = { }
uespLog.dumpIndexTable = { }
uespLog.dumpTableTable = { }
uespLog.countGlobal = 0
uespLog.countGlobalError = 0
uespLogcountVariables = {}

uespLog.baseTrackStatGameTime = GetGameTimeMilliseconds()

uespLog.UsedMerethicResin = false

uespLog.EnableSectionSizeWarning = false
uespLog.NextSectionSizeWarning = { }
uespLog.NextSectionWarningGameTime = { }
uespLog.NEXT_SECTION_SIZE_WARNING = 100
uespLog.FIRST_SECTION_SIZE_WARNING = 65000
uespLog.SECTION_SIZE_WARNING_COLOR = "ff9999"
uespLog.NEXT_SECTION_SIZE_WARNING_TIMEMS = 30000

	-- Objects to ignore when dumping
uespLog.dumpIgnoreObjects = { 
	["_G"] = 1, 
	["uespLog"] = 1, 
	["uespLogSavedVars"] = 1, 
	["uespLogCoordinates"] = 1, 
	["uespLogCoordinatesValue"] = 1,
	["uespLogUI"] = 1,
	["Zgoo"] = 1,
	["ZgooFrame"] = 1,
	["ZgooSV"] = 1,
	["ZGOO_ADDRESS_LOOKUP"] = 1
}

uespLog.MSG_LOOT = "loot"
uespLog.MSG_NPC = "npc"
uespLog.MSG_QUEST = "quest"
uespLog.MSG_XP = "xp"
uespLog.MSG_MISC = "misc"
uespLog.MSG_OTHER = uespLog.MSG_MISC
uespLog.MSG_INSPIRATION = "inspiration"

uespLog.lastConversationOption = { }
uespLog.lastConversationOption.Text = ""
uespLog.lastConversationOption.Type = ""
uespLog.lastConversationOption.Gold = ""
uespLog.lastConversationOption.Index = ""
uespLog.lastConversationOption.Important = ""

uespLog.lastLootUpdateCount = -1
uespLog.lastLootTargetName = ""
uespLog.lastLootTargetGameTime = 0
uespLog.lastLootTargetName1 = ""
uespLog.lastAntiquityGameOver = 0
uespLog.lastAntiquityIdLeadFound = 0
uespLog.isDiggingAntiquity = false
uespLog.lastLootLockQuality = nil

uespLog.savedVars = {}

	-- DayLength / OffsetMod / MoonStartMod
	-- 21000 / 3600 / 0
	-- 17280 / 9000 / 0
	-- 21000 / 4475 / 207360
uespLog.DEFAULT_GAMETIME_OFFSET = 1396569600 		-- Offset to make in-game date 1st Morning Star
uespLog.DEFAULT_GAMETIME_OFFSET_EXTRA = -1909707 	-- Extra offset to make in-game date on launch day 4th Rain's Hand,
uespLog.GAMETIME_WEEKDAY_OFFSET = 4					-- Weekday offset to make launch day Fredas
uespLog.GAMETIME_WEEKDAY_OFFSET = 2					-- Fix to match Clock v0.7.13
uespLog.DEFAULT_GAMETIME_YEAROFFSET = 582

uespLog.DEFAULT_REALSECONDSPERGAMEDAY = 20955
uespLog.DEFAULT_REALSECONDSPERGAMEYEAR = uespLog.DEFAULT_REALSECONDSPERGAMEDAY * 365
uespLog.DEFAULT_REALSECONDSPERGAMEHOUR = uespLog.DEFAULT_REALSECONDSPERGAMEDAY / 24
uespLog.DEFAULT_REALSECONDSPERGAMEMINUTE = uespLog.DEFAULT_REALSECONDSPERGAMEHOUR / 60
uespLog.DEFAULT_REALSECONDSPERGAMESECOND = uespLog.DEFAULT_REALSECONDSPERGAMEMINUTE / 60

uespLog.DEFAULT_MOONPHASETIME = 30 * uespLog.DEFAULT_REALSECONDSPERGAMEDAY
uespLog.DEFAULT_MOONPHASESTARTTIME = 1435838770 + uespLog.DEFAULT_MOONPHASETIME/2

uespLog.TES_MONTHS = {
	"Morning Star",
	"Sun's Dawn", 
	"First Seed",
	"Rain's Hand",
	"Second Seed",
	"Midyear",
	"Sun's Height",
	"Last Seed",
	"Hearthfire",
	"Frostfall",
	"Sun's Dusk",
	"Evening Star"
}
	
uespLog.TES_WEEKS = {
	"Sundas",
	"Morndas",
	"Tirdas",
	"Middas",
	"Turdas",
	"Fredas",
	"Loredas" 
}

uespLog.ignoredNPCs = {
	Familiar = 1,
	Cat = 1,
	Rat = 1,
	Lizard = 1,
	-- Mudcrab = 1,     -- Probably should track these as there are normal mobs and drop crafting supplies
	Horse = 1,
	Snake = 1,
	Scorpion = 1,
	Beetle = 1,
	Fox = 1,
	Goat = 1,
	Chicken = 1,
	Dog = 1,
	Rabbit = 1,
	-- Clannfear = 1,	-- Some of these are actual mobs as opposed to the Sorcerer pets
	Frog = 1,
	Deer = 1,
	Spider = 1,
	Torchbug = 1,
	Pig = 1, 
	Sheep = 1,
	Cow = 1,
	Butterfly = 1,
	Squirrel = 1,
	Centipede = 1,
	Fleshflies = 1,
	Monkey = 1,
	Wasp = 1,
	Honor = 1,
	Scuttler = 1,
	Scrib = 1,
	Antelope = 1,
	Ox = 1,
	Wormmouth = 1,  		--Craglorn
	Skavenger = 1, 			--Craglorn
	Fellrunner = 1,  		--Craglorn
	Daggerback = 1,  		--Craglorn
	["Fennec Fox"] = 1,  	--Craglorn
	["Thorn Geko"] = 1,  	--Craglorn
	["Pony Guar"] = 1,
	["Bantam Guar"] = 1,
	["Razak's Opus"] = 1,
	["Draft Horse"] = 1,
	["Light Horse"] = 1,
	["Restoring Twilight"] = 1,
	["Winged Twilight"] = 1,
	["Twilight Matriarch"] = 1,
	["Volatile Familiar"] = 1,
	["Thorn Gecko"] = 1,  	--Craglorn
	["Sandroach"] = 1,  	--Craglorn
	["Camel"] = 1,  		--Craglorn
	["Daedrat"] = 1,		--Imperial City
	["Fiendroth"] = 1,		--Imperial City
	["Bear Cub"] = 1,		--Orsinium
	["Pocket Mammoth"] = 1,	--Orsinium
	["Chub Loon"] = 1,		--Orsinium
	["Pack Echatere"] = 1,	--Orsinium
	["Echalette"] = 1,		--Orsinium
	["Sep Adder"] = 1,		--Thieves Guild
	["Dragon Frog"] = 1,	--Thieves Guild
	["Nixad"] = 1,			--Dark Brotherhood
	["Lynx"] = 1,			--Dark Brotherhood
	["Badger"] = 1,			--Dark Brotherhood
	["Heron"] = 1,			--Dark Brotherhood
	["Nuzhimeh"] = 1,
	["Tythis Andromo"] = 1,
	["Pirharri the Smuggler"] = 1,
	["Shroom Beetle"] = 1,	-- Morrowind
	["Dragonfly"] = 1,		-- Morrowind
	["Netch Calf"] = 1,		-- Morrowind
	["Fetcherfly"] = 1,		-- Morrowind
	["Ash Hopper"] = 1,		-- Morrowind
	["Cliff Skipper"] = 1,	-- Morrowind
	["Feral Guardian"] = 1,	-- Morrowind
	["Wild Guardian"] = 1,	-- Morrowind
	["Eternal Guardian"] = 1,	-- Morrowind
	["Vvardvark"] = 1,		-- Morrowind
	["Skeevaton"] = 1,		-- Clockwork City
	["Scorpion Fabricant"] = 1,		-- Clockwork City
	["Bright Moons Lunar Moth"] = 1, 	-- Summerset
	["Alinor Ringtail"] = 1, 	-- Summerset
	["Springbok"] = 1, 		-- Summerset
	["Mud Hopper"] = 1,		-- Summerset
	["Salamander Variant"] = 1,	-- Summerset
	["Lesser Sea Adder"] = 1,	-- Summerset
	["Fledgeling Gryphon"] = 1,	-- Summerset
	["Swamp Jelly"] = 1, 	-- Murkmire
	["Tangerine Dragon Frog"] = 1,	-- Elsweyr
	["Jerboa"] = 1,	-- Elsweyr
	["Elk"] = 1,	-- Greymoore
	["Cockroach"] = 1,	-- Greymoore
	["Winter Moth"] = 1,	-- Greymoore
	["Vale Buck Deer"] = 1,	-- Greymoore
	["Vale Doe Deer"] = 1,	-- Greymoore
	["Vale Deer Doe"] = 1,	-- Greymoore
	["Blackreach Jelly"] = 1,	-- Greymoore
	["Pack Guar"] = 1,
}

uespLog.lastTargetData = {
	type = "",
	name = "",
	x = "",
    y = "",
	worldx = "",
	worldy = "",
	worldz = "",
	worldzoneid = "",
    zone = "",
	gameTime = "",
	timeStamp = "",
	level = "",
	effectiveLevel = "",
	race = "",
	class = "",
	maxHp = "",
	maxMg = "",
	maxSt = "",
	action = "",
	interactionType = "",
	itemLink = "",
}

uespLog.lastOnTargetChange = ""
uespLog.lastOnTargetChangeGameTime = 0
uespLog.lastMoneyChange = 0
uespLog.lastMoneyGameTime = 0
uespLog.lastItemLink = ""
uespLog.lastItemLinks = { }
uespLog.lastItemLinkUsed = ""
uespLog.lastItemLinkTime = 0
uespLog.lastItemLinkUsed_BagId = -1
uespLog.lastItemLinkUsed_SlotIndex = -1
uespLog.lastItemLinkUsed_itemLinks = {}
uespLog.lastItemLinkUsed_Name = ""
uespLog.lastItemLinkUsed_itemNames = {}

uespLog.defaultColor = "EEEE00"
uespLog.debugColor = "999999"
uespLog.researchColor = "00ffff"
uespLog.timeColor = "00ffff"
uespLog.traitColor = "00ffff"
uespLog.craftColor = "66ffff"
uespLog.countColor = "00ffff"
uespLog.xpColor = "6699ff"
uespLog.itemColor = "ff9900"
uespLog.statColor = "44ffff"
uespLog.mineColor = "99ff99"
uespLog.mineColorWarning = "ff9999"
uespLog.pvpColor = "ff33ff"
uespLog.errorColor = "ff9999"
uespLog.warningColor = "ff9999"
uespLog.fishingColor = "9999ff"
uespLog.trackStatHeaColor = "FF3331"
uespLog.trackStatMagColor = "29A2DE"
uespLog.trackStatStaColor = "35F935"
uespLog.trackStatUltColor = "FFFFFF"

uespLog.LastKeepChatOpen = false

uespLog.MARKET_HIDE_TIME = 30	-- Seconds

uespLog.LastLoreBookTitle = ""
uespLog.LastLoreBookTime = 0

uespLog.currentTargetData = {
	name = "",
	x = "",
	y = "",
	zone = "",
	action = "",
	interactionType = "",
	worldx = "",
	worldy = "",
	worldz = "",
	worldzoneid = "",
}

uespLog.currentConversationData = {
    npcName = "",
    npcLevel = "",
    x = "",
    y = "",
    zone = "",
	worldx = "",
	worldy = "",
	worldz = "",
	worldzoneid = "",
}

uespLog.ALLIANCE_SHORT_NAMES = {
	[1] = "AD",
	[2] = "EP",
	[3] = "DC",
}

uespLog.ALLIANCE_NAMES = {
	[1] = "Aldmeri Dominion",
	[2] = "Ebonheart Pack",
	[3] = "Daggerfall Covenant",
}


uespLog.MINEITEM_UNSAFE_SUBTYPES = {
	[0]   = true,
	[10]  = true,
	[18]  = true,
	--[30]  = true,
	[37]  = true,
	[38]  = true,
	[241] = true,
	[242] = true,
	[243] = true,
	[244] = true,
	[245] = true,
	[253] = true,
	[277] = true,
	[278] = true,
	[279] = true,
	[280] = true,
	[281] = true,
	[282] = true,
	[295] = true,
	[296] = true,
	[297] = true,
	[298] = true,
	[299] = true,
	[313] = true,
	[314] = true,
	[315] = true,
	[316] = true,
	[317] = true,
	[319] = true,
	[323] = true,
	[324] = true,
	[325] = true,
	[326] = true,
	[327] = true,
	[328] = true,
	[329] = true,
	[330] = true,
	[331] = true,
	[332] = true,
	[333] = true,
	[334] = true,
	[335] = true,
	[336] = true,
	[337] = true,
	[338] = true,
}


uespLog.MINEITEM_LEVELS = {
	{  1, 50,   0,  11, "dropped" },
	{  1, 50,  18,  19, "unknown" },
	{  1, 50,  20,  24, "crafted" },
	{  1,  4,  25,  29, "crafted" },
	{  1, 50,  30,  31, "crafted" },
	{  1,  1,  32,  34, "crafted" },
	{  1, 50,  37,  38, "unknown" },
	{ 50, 50,  39,  48, "quest" },
	{  1, 50,  49,  50, "unknown" },
	{ 50, 50,  51,  60, "dropped" },
	{ 50, 50,  61,  70, "dropped" },
	{ 50, 50,  71,  80, "unknown" },
	{ 50, 50,  81,  90, "dropped" },
	{ 50, 50,  91, 100, "dropped" },
	{ 50, 50, 101, 110, "dropped" },
	{ 50, 50, 111, 120, "dropped/sold" },
	{  1, 50, 121, 124, "unknown" },
	{ 50, 50, 125, 134, "crafted" },
	{ 50, 50, 135, 144, "crafted" },
	{ 50, 50, 145, 154, "crafted" },
	{ 50, 50, 155, 164, "crafted" },
	{ 50, 50, 165, 174, "crafted" },
	{  1, 50, 175, 175, "unknown" },
	{  1, 50, 177, 177, "unknown" },
	{ 50, 50, 188, 188, "unknown" },
	{ 50, 50, 208, 208, "unknown" },
	{ 50, 50, 228, 234, "unknown" },
	{ 50, 50, 235, 235, "store" },
	{ 50, 50, 236, 240, "crafted" }, --VR11
	{ 50, 50, 241, 245, "dropped" }, --VR11
	{ 50, 50, 246, 247, "unknown" },
	{ 50, 50, 248, 251, "dropped" },
	{ 50, 50, 253, 253, "store" },
	{ 50, 50, 254, 258, "crafted" },
	{ 50, 50, 259, 267, "dropped" },
	{ 50, 50, 268, 271, "unknown" },
	{ 50, 50, 272, 276, "crafted" },
	{ 50, 50, 277, 281, "dropped" },
	{ 50, 50, 282, 282, "unknown" },
	{ 50, 50, 283, 285, "dropped" },
	{ 50, 50, 286, 289, "unknown" },
	{ 50, 50, 290, 294, "crafted" },
	{ 50, 50, 295, 299, "dropped" },
	{ 50, 50, 300, 300, "unknown" },
	{ 50, 50, 301, 301, "dropped" },
	{ 50, 50, 304, 307, "dropped" },
	{ 50, 50, 308, 312, "crafted" },
	{ 50, 50, 313, 317, "dropped" },
	{  1, 50, 319, 319, "novalue" },
	{ 50, 50, 323, 338, "novalue" },
	{ 50, 50, 358, 364, "dropped" },
	{ 50, 50, 365, 365, "unknown" },
	{ 50, 50, 366, 370, "crafted" },
	{ 50, 50, 378, 378, "unknown" },
}


uespLog.MINEITEM_LEVELS_SAFE = {
	{  0,  1,   0,   1, "?" },
	{  1, 50,   1,   9, "dropped" },
	{  1, 50,  11,  11, "dropped" },
	{  1, 50,  19,  19, "unknown" },
	{  1, 50,  20,  24, "crafted" },
	{  1,  4,  25,  29, "crafted" },
	{  1, 50,  30,  31, "crafted" },
	{  1,  1,  32,  34, "crafted" },
	{ 50, 50,  39,  48, "quest" },
	{  1, 50,  49,  50, "unknown" },
	{ 50, 50,  51,  60, "dropped" },
	{ 50, 50,  61,  70, "dropped" },
	{ 50, 50,  71,  80, "unknown" },
	{ 50, 50,  81,  90, "dropped" },
	{ 50, 50,  91, 100, "dropped" },
	{ 50, 50, 101, 110, "dropped" },
	{ 50, 50, 111, 120, "dropped/sold" },
	{  1, 50, 121, 124, "unknown" },
	{ 50, 50, 125, 134, "crafted" },
	{ 50, 50, 135, 144, "crafted" },
	{ 50, 50, 145, 154, "crafted" },
	{ 50, 50, 155, 164, "crafted" },
	{ 50, 50, 165, 174, "crafted" },
	{  1, 50, 175, 175, "unknown" },
	{  1, 50, 177, 177, "unknown" },
	{ 50, 50, 188, 188, "unknown" },
	{ 50, 50, 208, 208, "unknown" },
	{ 50, 50, 228, 234, "unknown" },
	{ 50, 50, 235, 235, "store" },
	{ 50, 50, 236, 240, "crafted" }, --VR11
	{ 50, 50, 246, 247, "unknown" },
	{ 50, 50, 248, 251, "dropped" },
	{ 50, 50, 253, 253, "store" },
	{ 50, 50, 254, 258, "crafted" },
	{ 50, 50, 264, 267, "dropped" },
	{ 50, 50, 268, 271, "unknown" },
	{ 50, 50, 272, 273, "crafted" },	-- 274 bad
	{ 50, 50, 275, 276, "crafted" },
	{ 50, 50, 283, 285, "dropped" },
	{ 50, 50, 286, 289, "unknown" },	-- All bad?
	{ 50, 50, 290, 294, "crafted" },
	{ 50, 50, 300, 300, "unknown" },
	{ 50, 50, 301, 301, "dropped" },
	{ 50, 50, 304, 307, "dropped" },
	{ 50, 50, 308, 312, "crafted" },
	{ 50, 50, 358, 364, "dropped" },
	{ 50, 50, 365, 365, "unknown" },
	{ 50, 50, 366, 370, "crafted" },
	{ 50, 50, 378, 378, "unknown" },
}


uespLog.MINEITEM_LEVELS_SHORT = {
	{  1, 50,   1,  11, "dropped" },
	{  1, 50,  18,  19, "unknown" },
	{  1, 50,  20,  24, "crafted" },
	{  1,  4,  25,  29, "crafted" },
	{  1, 50,  30,  31, "crafted" },
	{  1,  1,  32,  34, "crafted" },
	{  1, 50,  37,  38, "unknown" },
	{ 50, 50,  39,  48, "quest" },
	{  1, 50,  49,  50, "unknown" },
	{ 50, 50,  51,  60, "dropped" },
	{ 50, 50,  61,  70, "dropped" },
	{ 50, 50,  71,  80, "unknown" },
	{ 50, 50,  81,  90, "dropped" },
	{ 50, 50,  91, 100, "dropped" },
	{ 50, 50, 111, 120, "dropped/sold" },
	{  1, 50, 121, 124, "unknown" },
	{ 50, 50, 125, 125, "crafted" },
	{ 50, 50, 127, 127, "crafted" },
	{ 50, 50, 129, 129, "crafted" },
	{ 50, 50, 131, 131, "crafted" },
	{ 50, 50, 134, 134, "crafted" },
	{  1, 50, 175, 175, "unknown" },
	{  1, 50, 177, 177, "unknown" },
	{ 50, 50, 188, 188, "unknown" },
	{ 50, 50, 208, 208, "unknown" },
	{ 50, 50, 228, 234, "unknown" },
	{ 50, 50, 235, 235, "store" },
	{ 50, 50, 246, 247, "unknown" },
	{ 50, 50, 248, 251, "dropped" },
	{ 50, 50, 253, 253, "store" },
	{ 50, 50, 265, 267, "dropped" },
	{ 50, 50, 268, 271, "unknown" },
	{ 50, 50, 282, 282, "unknown" },
	{ 50, 50, 283, 285, "dropped" },
	{ 50, 50, 286, 289, "unknown" },
	{ 50, 50, 300, 300, "unknown" },
	{ 50, 50, 301, 301, "dropped" },
	{ 50, 50, 304, 307, "dropped" },
	{ 50, 50, 308, 309, "crafted" },
	{  1, 50, 319, 319, "novalue" },
	{ 50, 50, 324, 337, "novalue" },
	{ 50, 50, 358, 364, "dropped" },
	{ 50, 50, 365, 365, "unknown" },
	{ 50, 50, 366, 366, "crafted" },
	{ 50, 50, 378, 378, "unknown" },
}


uespLog.MINEITEM_LEVELS_SHORT_SAFE = {
	{  1, 50,   1,   9, "dropped" },
	{  1, 50,  11,  11, "dropped" },
	{  1, 50,  19,  19, "unknown" },
	{  1, 50,  20,  24, "crafted" },
	{  1,  4,  25,  29, "crafted" },
	{  1, 50,  31,  31, "crafted" },
	{  1,  1,  32,  34, "crafted" },
	{ 50, 50,  39,  48, "quest" },
	{  1, 50,  49,  50, "unknown" },
	{ 50, 50,  51,  60, "dropped" },
	{ 50, 50,  61,  70, "dropped" },
	{ 50, 50,  71,  80, "unknown" },
	{ 50, 50,  81,  90, "dropped" },
	{ 50, 50,  91, 100, "dropped" },
	{ 50, 50, 111, 120, "dropped/sold" },
	{  1, 50, 121, 124, "unknown" },
	{ 50, 50, 125, 125, "crafted" },
	{ 50, 50, 127, 127, "crafted" },
	{ 50, 50, 129, 129, "crafted" },
	{ 50, 50, 131, 131, "crafted" },
	{ 50, 50, 134, 134, "crafted" },
	{  1, 50, 175, 175, "unknown" },
	{  1, 50, 177, 177, "unknown" },
	{ 50, 50, 188, 188, "unknown" },
	{ 50, 50, 208, 208, "unknown" },
	{ 50, 50, 228, 234, "unknown" },
	{ 50, 50, 235, 235, "store" },
	{ 50, 50, 246, 247, "unknown" },
	{ 50, 50, 248, 251, "dropped" },
	{ 50, 50, 253, 253, "store" },
	{ 50, 50, 265, 267, "dropped" },
	{ 50, 50, 268, 271, "unknown" },
	{ 50, 50, 283, 285, "dropped" },
	{ 50, 50, 286, 289, "unknown" },
	{ 50, 50, 300, 300, "unknown" },
	{ 50, 50, 301, 301, "dropped" },
	{ 50, 50, 304, 307, "dropped" },
	{ 50, 50, 308, 309, "crafted" },
	{ 50, 50, 358, 364, "dropped" },
	{ 50, 50, 365, 365, "unknown" },
	{ 50, 50, 366, 366, "crafted" },
	{ 50, 50, 378, 378, "unknown" },
}


uespLog.MINEITEM_SPARSE = {
	{  0,  1,   1,   1, "" },
	{  1,  1,   3,   9, "" },
	{  1,  1,  20,  20, "" },
	{  1,  1,  22,  23, "" },
	{  1,  1,  25,  25, "" },
	{  1,  1,  29,  29, "" },
	{  1,  1,  31,  31, "" },
	{  1,  1, 177, 177, "" },
	{  1, 50,  24,  24, "" },
	{ 50, 50,  75,  75, "" },
	{ 50, 50,  75,  75, "" },
	{ 50, 50,  77,  77, "" },
	{ 50, 50,  79,  79, "" },
	{ 50, 50, 102, 110, "" },
	{ 50, 50, 231, 231, "" },
	{ 50, 50, 234, 234, "" },
	{ 50, 50, 258, 258, "" },
	{ 50, 50, 267, 267, "" },
	{ 50, 50, 270, 270, "" },
	{ 50, 50, 288, 288, "" },
	{ 50, 50, 306, 306, "" },
	{ 50, 50, 363, 363, "" },
	{ 50, 50, 370, 370, "" },
}


uespLog.MINEITEM_ITEMCOUNTESTIMATE = 72000
--uespLog.MINEITEM_SHIELDARMORFACTOR = 1.0/1.75
uespLog.MINEITEM_SHIELDARMORFACTOR = 1
uespLog.MINEITEM_ONLYSUBTYPE = 366
uespLog.MINEITEM_ONLYLEVEL = 50

uespLog.mineItemBadCount = 0
uespLog.mineItemCount = 0
uespLog.mineUpdateItemCount = 0
uespLog.mineNextItemId = 1
uespLog.isAutoMiningItems = false
uespLog.MINEITEMS_AUTODELAY = 1000 -- Delay in ms
uespLog.MINEITEMS_AUTOLOOPCOUNT = 400
uespLog.MINEITEMS_AUTOMAXLOOPCOUNT = 400
uespLog.MINEITEM_AUTO_MAXITEMID = 200000
uespLog.mineItemsAutoNextItemId = 1
uespLog.mineItemsAutoNextListIndex = 1
uespLog.mineItemsAutoLastItemId = uespLog.MINEITEM_AUTO_MAXITEMID
uespLog.mineItemsEnabled = false
uespLog.MINEITEMS_AUTOSTOP_LOGCOUNT = 50000
uespLog.mineItemAutoReload = false
uespLog.mineItemLastReloadTimeMS = GetGameTimeMilliseconds()
uespLog.MINEITEM_AUTORELOAD_DELTATIMEMS = 1000  -- Default value, use uespLog.minedItemReloadDelay instead
uespLog.mineItemAutoRestart = false
uespLog.mineItemAutoRestartOutputEnd = false
uespLog.mineItemOnlySubType = -1
uespLog.mineItemOnlyItemType = {}
uespLog.mineItemOnlyLevel = -1
uespLog.MINEITEM_QUALITYMAP_ITEMID = 47000
uespLog.MINEITEM_IDCHECK_NUMITEMS = 5000
uespLog.MINEITEM_IDCHECK_TIMEDELTA = 2000
uespLog.CurrentIdCheckItemId = 1
uespLog.IsIdCheckInProgress = false
uespLog.IdCheckRangeIdStart = -1
uespLog.IdCheckValidCount = 0
uespLog.IdCheckTotalCount = 0
uespLog.mineItemReloadDelay = uespLog.MINEITEM_AUTORELOAD_DELTATIMEMS
uespLog.mineItemPotionDataEffectIndex = 0
uespLog.mineItemPotionDataListIndex = 1
uespLog.MINEITEM_POTION_MAXEFFECTINDEX = 32
uespLog.MINEITEM_POTION_ITEMID = 54339
uespLog.MINEITEM_POISON_ITEMID = 76847
uespLog.MINEITEM_POTION_MAGICITEMID = 1	-- 1234567
uespLog.MINEITEM_POISON_MAGICITEMID = 2
uespLog.MINEITEM_ENCHANT_ITEMID = 55679
uespLog.MINEITEM_ENCHANT_ENCHANTID = 26841

uespLog.MASTERWRIT_MAX_CHANCE = 15
uespLog.MASTERWRIT_MIN_CHANCE = 1
uespLog.PROV_MASTERWRIT_RECIPELISTS = { 7, 14, 15, 16}

uespLog.DEFAULT_DATA = 
{
	data = {}
}

uespLog.DEFAULT_CHARINFO = 
{
	data = {
		["dailyQuestData"] = {},
		["lastFoodEaten"] = "",
		["hirelingMailTime"] = {
			[CRAFTING_TYPE_PROVISIONING] = 0,
			[CRAFTING_TYPE_WOODWORKING] = 0,
			[CRAFTING_TYPE_BLACKSMITHING] = 0,
			[CRAFTING_TYPE_ENCHANTING] = 0,
			[CRAFTING_TYPE_CLOTHIER] = 0,
		},
		["questStageData"] = {},
		["questUniqueIds"] = {},
	}
}

uespLog.DEFAULT_BUILDDATA = 
{
	data = {}
}

uespLog.DEFAULT_BANKDATA = 
{
	data = {}
}

uespLog.DEFAULT_CRAFTBAGDATA = 
{
	data = {}
}

uespLog.DEFAULT_SKILLCOEF_DATA = 
{
	data = 
	{
		coefData = {},
		abilityData = {},
	}
}

uespLog.DEFAULT_CHARDATA = 
{
	data = {}
}


uespLog.DEFAULT_SETTINGS = 
{
	data = {
		["debug"] = false,
		["debugExtra"] = false,
		["logData"] = false,
		["color"] = true,
		["totalInspiration"] = 0,
		["craft"] = true,
		["craftStyle"] = "both",
		["craftTrait"] = "both",
		["craftRecipe"] = "both",
		["showTraitIcon"] = false,
		["craftIngredient"] = "both",
		["craftAutoLoot"] = false,
		["craftAutoLootMinProvLevel"] = 1,
		["mailDeleteNotify"] = false,
		["mineItemsAutoNextItemId"] = 1,
		["mineItemsAutoNextListIndex"] = 1,
		["mineItemsAutoLastItemId"] = uespLog.MINEITEM_AUTO_MAXITEMID,
		["mineItemAutoReload"] = false,
		["mineItemAutoRestart"] = false,
		["mineItemsEnabled"] = false,
		["mineItemOnlySubType"] = -1,
		["mineItemOnlyItemType"] = {},
		["mineItemOnlyLevel"] = -1,
		["mineItemPotionData"] = false,
		["mineItemReloadDelay"] = uespLog.MINEITEM_AUTORELOAD_DELTATIMEMS,
		["showCursorMapCoords"] = true,
		["isAutoMiningItems"] = false,
		["pvpUpdate"] = false,
		["enabledTreasureTimers"] = false,
		["TREASURE_TIMER_DURATIONS"] = {
			["chest"] = 120,
			["heavy sack"] = 120,
			["safebox"] = 120,
			["thieves trove"] = 300,
		},
		["loreBookMsg"] = true,
		["autoSaveCharData"] = false,
		["saveExtendedCharData"] = true,
		["autoSaveZoneCharData"] = false,
		["charDataPassword"] = "",
		["charDataOldPassword"] = "",
		["fishing"] = false,
		["trackStat"] = { 
			[POWERTYPE_MAGICKA] = false,
			[POWERTYPE_HEALTH] = false,
			[POWERTYPE_STAMINA] = false,
			[POWERTYPE_ULTIMATE] = false,
			["Weapon Damage"] = false,
			["Spell Damage"] = false,
		},
		["containerAutoLoot"] = false,
		["customStatDisplay"] = "off",
		["targetResistance"] = 18200,
		["targetCritResistFactor"] = 0,
		["targetCritResistFlat"] = 0,
		["messageDisplay"] = {
			[uespLog.MSG_LOOT] = false,
			[uespLog.MSG_QUEST] = false,
			[uespLog.MSG_NPC] = false,
			[uespLog.MSG_XP] = false,
			[uespLog.MSG_MISC] = false,
			[uespLog.MSG_INSPIRATION] = false,
		},		
		["trackLoot"] = false,
		["trackFights"] = false,
		["inventoryStats"] = "off",
		["salesData"] = {
			["saveSales"] = true,
			["showPrices"] = false,
			["showTooltip"] = true,
			["showSaleType"] = "both",
			["showDealType"] = "uesp",
			["postPriceType"] = "uesp",
			["lastTimestamp"] = 0,
			["guildListTimes"] = {},
			["useWritWorthy"] = false,
			["savedPrices"] = {},
			[1] = {
				["guildName"] = "",
				["guildId"] = 1,
				["lastTimestamp"] = 0,
			},
			[2] = {
				["guildName"] = "",
				["guildId"] = 2,
				["lastTimestamp"] = 0,
			},
			[3] = {
				["guildName"] = "",
				["guildId"] = 3,
				["lastTimestamp"] = 0,
			},
			[4] = {
				["guildName"] = "",
				["guildId"] = 4,
				["lastTimestamp"] = 0,
			},
			[5] = {
				["guildName"] = "",
				["guildId"] = 5,
				["lastTimestamp"] = 0,
			},
		},
		["nirnSound"] = false,
		["alchemyTooltip"] = false,
		["maxQualityForTraitResearch"] = 0,
		["includeSetItemsForTraitResearch"] = true,
		["autolootHirelingMails"] = false,
		["keepChatOpen"] = false,
		["closeMarketAnnouncement"] = false,
	}
}

	-- Skill lines missing from PTS for skill dumps
	--		index, rank, abilityId, learnedLevel, skillLine, type, abilityType, skillType
uespLog.MISSING_SKILL_DATA = {
	{ 1, 1, 63799, 1, "Legerdemain", 1 },     -- Improved Hiding
	{ 1, 2, 63800, 6, "Legerdemain", 1 },
	{ 1, 3, 63801, 11, "Legerdemain", 1 },
	{ 1, 4, 63802, 16, "Legerdemain", 1 },
	{ 2, 1, 63803, 2, "Legerdemain", 1 },     -- Light Fingers
	{ 2, 2, 63804, 7, "Legerdemain", 1 },
	{ 2, 3, 63805, 12, "Legerdemain", 1 },
	{ 2, 4, 63806, 17, "Legerdemain", 1 },
	{ 3, 1, 63807, 3, "Legerdemain", 1 },     -- Trafficker
	{ 3, 2, 63808, 8, "Legerdemain", 1 },
	{ 3, 3, 63809, 13, "Legerdemain", 1 },
	{ 3, 4, 63810, 18, "Legerdemain", 1 },
	{ 4, 1, 63811, 5, "Legerdemain", 1 },     -- Locksmith
	{ 4, 2, 63812, 9, "Legerdemain", 1 },
	{ 4, 3, 63813, 14, "Legerdemain", 1 },
	{ 4, 4, 63814, 19, "Legerdemain", 1 },
	{ 5, 1, 63815, 6, "Legerdemain", 1 },     -- Kickback
	{ 5, 2, 63816, 10, "Legerdemain", 1 },
	{ 5, 3, 63817, 15, "Legerdemain", 1 },
	{ 5, 4, 63818, 20, "Legerdemain", 1 },
	{ 1, 1, 44625, 1, "Provisioning", 1 },     -- Recipe Quality
	{ 1, 2, 44630, 10, "Provisioning", 1 },
	{ 1, 3, 44631, 35, "Provisioning", 1 },
	{ 1, 4, 69953, 50, "Provisioning", 1 },
	{ 2, 1, 44590, 1, "Provisioning", 1 },     -- Recipe Improvement
	{ 2, 2, 44595, 20, "Provisioning", 1 },
	{ 2, 3, 44597, 25, "Provisioning", 1 },
	{ 2, 4, 44598, 30, "Provisioning", 1 },
	{ 2, 5, 44599, 50, "Provisioning", 1 },
	{ 2, 6, 44650, 60, "Provisioning", 1 },
	{ 3, 1, 44602, 3, "Provisioning", 1 },     -- Gourmand
	{ 3, 2, 44609, 14, "Provisioning", 1 },
	{ 3, 3, 44610, 43, "Provisioning", 1 },
	{ 4, 1, 44612, 5, "Provisioning", 1 },     -- Connoisseur
	{ 4, 2, 44614, 25, "Provisioning", 1 },
	{ 4, 3, 44615, 47, "Provisioning", 1 },
	{ 5, 1, 44616, 7, "Provisioning", 1 },     -- Chef
	{ 5, 2, 44617, 23, "Provisioning", 1 },
	{ 5, 3, 44619, 33, "Provisioning", 1 },
	{ 6, 1, 44620, 9, "Provisioning", 1 },     -- Brewer
	{ 6, 2, 44621, 25, "Provisioning", 1 },
	{ 6, 3, 44624, 36, "Provisioning", 1 },
	{ 7, 1, 44634, 28, "Provisioning", 1 },     -- Hireling
	{ 7, 2, 44640, 38, "Provisioning", 1 },
	{ 7, 3, 44641, 48, "Provisioning", 1 },
	{ 1, 1, 32624, 5, "Vampire", 2 },     -- Bat Swarm
	{ 1, 2, 41918, 5, "Vampire", 2 },
	{ 1, 3, 41919, 5, "Vampire", 2 },
	{ 1, 4, 41920, 5, "Vampire", 2 },
	{ 1, 5, 38932, 5, "Vampire", 2 },     -- Clouding Swarm
	{ 1, 6, 41924, 5, "Vampire", 2 },
	{ 1, 7, 41925, 5, "Vampire", 2 },
	{ 1, 8, 41926, 5, "Vampire", 2 },
	{ 1, 9, 38931, 5, "Vampire", 2 },     -- Devouring Swarm
	{ 1, 10, 41933, 5, "Vampire", 2 },
	{ 1, 11, 41936, 5, "Vampire", 2 },
	{ 1, 12, 41937, 5, "Vampire", 2 },
	{ 2, 1, 32893, 1, "Vampire", 0 },     -- Drain Essence
	{ 2, 2, 41864, 1, "Vampire", 0 },
	{ 2, 3, 41865, 1, "Vampire", 0 },
	{ 2, 4, 41866, 1, "Vampire", 0 },
	{ 2, 5, 38949, 1, "Vampire", 0 },     -- Invigorating Drain
	{ 2, 6, 41900, 1, "Vampire", 0 },
	{ 2, 7, 41901, 1, "Vampire", 0 },
	{ 2, 8, 41902, 1, "Vampire", 0 },
	{ 2, 9, 38956, 1, "Vampire", 0 },     -- Accelerating Drain
	{ 2, 10, 41879, 1, "Vampire", 0 },
	{ 2, 11, 41880, 1, "Vampire", 0 },
	{ 2, 12, 41881, 1, "Vampire", 0 },
	{ 3, 1, 32986, 1, "Vampire", 0 },     -- Mist Form
	{ 3, 2, 41807, 1, "Vampire", 0 },
	{ 3, 3, 41808, 1, "Vampire", 0 },
	{ 3, 4, 41809, 1, "Vampire", 0 },
	{ 3, 5, 38963, 1, "Vampire", 0 },     -- Elusive Mist
	{ 3, 6, 41813, 1, "Vampire", 0 },
	{ 3, 7, 41814, 1, "Vampire", 0 },
	{ 3, 8, 41815, 1, "Vampire", 0 },
	{ 3, 9, 38965, 1, "Vampire", 0 },     -- Poison Mist
	{ 3, 10, 41822, 1, "Vampire", 0 },
	{ 3, 11, 41823, 1, "Vampire", 0 },
	{ 3, 12, 41824, 1, "Vampire", 0 },
	{ 4, 1, 42054, 2, "Vampire", 1 },     -- Savage Feeding
	{ 4, 2, 46045, 4, "Vampire", 1 },
	{ 5, 1, 33095, 4, "Vampire", 1 },     -- Supernatural Recovery
	{ 5, 2, 46041, 7, "Vampire", 1 },
	{ 6, 1, 33091, 6, "Vampire", 1 },     -- Blood Ritual
	{ 7, 1, 33096, 7, "Vampire", 1 },     -- Undeath
	{ 7, 2, 46040, 10, "Vampire", 1 },
	{ 8, 1, 33093, 8, "Vampire", 1 },     -- Unnatural Resistance
	{ 9, 1, 33090, 9, "Vampire", 1 },     -- Dark Stalker
	{ 1, 1, 32455, 1, "Werewolf", 2 },     -- Werewolf Transformation
	{ 1, 2, 42356, 1, "Werewolf", 2 },
	{ 1, 3, 42357, 1, "Werewolf", 2 },
	{ 1, 4, 42358, 1, "Werewolf", 2 },
	{ 1, 5, 39075, 1, "Werewolf", 2 },     -- Pack Leader
	{ 1, 6, 42365, 1, "Werewolf", 2 },
	{ 1, 7, 42366, 1, "Werewolf", 2 },
	{ 1, 8, 42367, 1, "Werewolf", 2 },
	{ 1, 9, 39076, 1, "Werewolf", 2 },     -- Werewolf Berserker
	{ 1, 10, 42377, 1, "Werewolf", 2 },
	{ 1, 11, 42378, 1, "Werewolf", 2 },
	{ 1, 12, 42379, 1, "Werewolf", 2 },
	{ 2, 1, 32632, 2, "Werewolf", 0 },     -- Pounce
	{ 2, 2, 42108, 2, "Werewolf", 0 },
	{ 2, 3, 42109, 2, "Werewolf", 0 },
	{ 2, 4, 42110, 2, "Werewolf", 0 },
	{ 2, 5, 39105, 2, "Werewolf", 0 },     -- Brutal Pounce
	{ 2, 6, 42117, 2, "Werewolf", 0 },
	{ 2, 7, 42118, 2, "Werewolf", 0 },
	{ 2, 8, 42119, 2, "Werewolf", 0 },
	{ 2, 9, 39104, 2, "Werewolf", 0 },     -- Feral Pounce
	{ 2, 10, 42126, 2, "Werewolf", 0 },
	{ 2, 11, 42127, 2, "Werewolf", 0 },
	{ 2, 12, 42128, 2, "Werewolf", 0 },
	{ 3, 1, 58310, 3, "Werewolf", 0 },		-- Hircine's Bounty
	{ 3, 2, 58314, 3, "Werewolf", 0 },
	{ 3, 3, 58315, 3, "Werewolf", 0 },
	{ 3, 4, 58316, 3, "Werewolf", 0 },
	{ 3, 5, 58317, 3, "Werewolf", 0 },		-- Hircine's Rage
	{ 3, 6, 58319, 3, "Werewolf", 0 },
	{ 3, 7, 58321, 3, "Werewolf", 0 },
	{ 3, 8, 58323, 3, "Werewolf", 0 },
	{ 3, 9, 58325, 3, "Werewolf", 0 },		-- Hircine's Fortitude
	{ 3, 10, 58329, 3, "Werewolf", 0 },
	{ 3, 11, 58332, 3, "Werewolf", 0 },
	{ 3, 12, 58334, 3, "Werewolf", 0 },
	{ 4, 1, 32633, 5, "Werewolf", 0 },     -- Roar
	{ 4, 2, 42143, 5, "Werewolf", 0 },
	{ 4, 3, 42144, 5, "Werewolf", 0 },
	{ 4, 4, 42145, 5, "Werewolf", 0 },
	{ 4, 5, 39113, 5, "Werewolf", 0 },     -- Ferocious Roar
	{ 4, 6, 42155, 5, "Werewolf", 0 },
	{ 4, 7, 42156, 5, "Werewolf", 0 },
	{ 4, 8, 42157, 5, "Werewolf", 0 },
	{ 4, 9, 39114, 5, "Werewolf", 0 },     -- Rousing Roar
	{ 4, 10, 42177, 5, "Werewolf", 0 },
	{ 4, 11, 42178, 5, "Werewolf", 0 },
	{ 4, 12, 42179, 5, "Werewolf", 0 },
	{ 5, 1, 58405, 6, "Werewolf", 0 },		-- Piercing Howl
	{ 5, 2, 58736, 6, "Werewolf", 0 },
	{ 5, 3, 58738, 6, "Werewolf", 0 },
	{ 5, 4, 58740, 6, "Werewolf", 0 },
	{ 5, 5, 58742, 6, "Werewolf", 0 },		-- Howl of Despair
	{ 5, 6, 58786, 6, "Werewolf", 0 },
	{ 5, 7, 58790, 6, "Werewolf", 0 },
	{ 5, 8, 58794, 6, "Werewolf", 0 },
	{ 5, 9, 58798, 6, "Werewolf", 0 },		-- Howl of Agony
	{ 5, 10, 58802, 6, "Werewolf", 0 },
	{ 5, 11, 58805, 6, "Werewolf", 0 },
	{ 5, 12, 58808, 6, "Werewolf", 0 },
	{ 6, 1, 58855, 9, "Werewolf", 0 },		-- Infectious Claws
	{ 6, 2, 58857, 9, "Werewolf", 0 },
	{ 6, 3, 58859, 9, "Werewolf", 0 },
	{ 6, 4, 58862, 9, "Werewolf", 0 },
	{ 6, 5, 58864, 9, "Werewolf", 0 },		-- Claws of Anguish
	{ 6, 6, 58870, 9, "Werewolf", 0 },
	{ 6, 7, 58873, 9, "Werewolf", 0 },
	{ 6, 8, 58876, 9, "Werewolf", 0 },
	{ 6, 9, 58879, 9, "Werewolf", 0 },		-- Claws of Life
	{ 6, 10, 58901, 9, "Werewolf", 0 },
	{ 6, 11, 58904, 9, "Werewolf", 0 },
	{ 6, 12, 58907, 9, "Werewolf", 0 },
	{ 7, 1, 32636, 3, "Werewolf", 1 },     -- Pursuit
	{ 7, 2, 46142, 7, "Werewolf", 1 },
	{ 8, 1, 32634, 3, "Werewolf", 1 },     -- Devour
	{ 9, 1, 32637, 4, "Werewolf", 1 },     -- Blood Rage
	{ 9, 2, 46135, 8, "Werewolf", 1 },
	{ 10, 1, 32639, 6, "Werewolf", 1 },     -- Bloodmoon
	{ 11, 1, 32638, 6, "Werewolf", 1 },     -- Savage Strength
	{ 11, 2, 46139, 9, "Werewolf", 1 },
	{ 12, 1, 32641, 7, "Werewolf", 1 },     -- Call of the Pack
	{ 12, 2, 46137, 10, "Werewolf", 1 },
	{ 1, 1, 39644, 1, "Emperor", 1 },     -- Domination
	{ 2, 1, 39630, 1, "Emperor", 1 },     -- Authority
	{ 3, 1, 39625, 1, "Emperor", 1 },     -- Monarch
	{ 4, 1, 39647, 1, "Emperor", 1 },     -- Tactician
	{ 5, 1, 39641, 1, "Emperor", 1 },     -- Emperor
	{ 1, 1, 74580, 1, "Thieves Guild", 1 },     -- Finders Keepers
	{ 4, 1, 76451, 4, "Thieves Guild", 1 },     -- Clemency
	{ 5, 1, 76452, 7, "Thieves Guild", 1 },     -- Timely Escape
	{ 6, 1, 76453, 10, "Thieves Guild", 1 },     -- Veil of Shadows
	{ 1, 1, 76325, 1, "Dark Brotherhood", 1, 4 },     -- Blade of Woe
	{ 2, 1, 77392, 2, "Dark Brotherhood", 1, 4 },     -- Scales of Pitiless Justice
	{ 2, 2, 77394, 5, "Dark Brotherhood", 1, 4 },
	{ 2, 3, 77395, 8, "Dark Brotherhood", 1, 4 },
	{ 2, 4, 79865,11, "Dark Brotherhood", 1, 4 },
	{ 3, 1, 77397, 3, "Dark Brotherhood", 1, 4 },		-- Padomaic Spirit
	{ 3, 2, 77398, 6, "Dark Brotherhood", 1, 4 },
	{ 3, 3, 77399, 9, "Dark Brotherhood", 1, 4 },
	{ 3, 4, 79868,12, "Dark Brotherhood", 1, 4 },
	{ 4, 1, 77396, 4, "Dark Brotherhood", 1, 4 },		-- Shadowy Supplier
	{ 5, 1, 77400, 7, "Dark Brotherhood", 1, 4 },		-- Shadow Rider
	{ 6, 1, 77401,10, "Dark Brotherhood", 1, 4 },		-- Spectral Assassin
}


uespLog.ITEMCHANGE_IGNORE_FIELDS = { 
	['level'] = 1,  
	['reqLevel'] = 1, 
	['reqCP'] = 1, 
	['quality'] = 1,
	['itemLink'] = 1,	
}


uespLog.RUNEBOX_COLLECTIBLE_IDS = {
        [79329] = 148,  		-- Xivkyn Dreadguard
        [79330] = 147,  		-- Xivkyn Tormentor
        [79331] = 146,  		-- Xivkyn Augur
        [83516] = 439,  		-- Pumpkin Spectre Mask
        [83517] = 440,  		-- Scarecrow Spectre Mask
        [96391] = 601,  		-- Mud Ball Pouch
        [96392] = 597,  		-- Sword-Swallower's Blade
        [96393] = 598,  		-- Juggler's Knives
        [96395] = 600,  		-- Fire-Breather's Torches
        [96951] = 753,  		-- Nordic Bather's Towel
        [96952] = 755,  		-- Colovian Fur Hood
        [96953] = 754,  		-- Colovian Filigreed Hood
        [119692] = 1108,        -- Cherry Blossom Branch
        [124658] = 1232,        -- Dwarven Theodolite
        [124659] = 1230,        -- Sixth House Robe
        [128359] = 1338,        -- Hollowjack Spectre Mask
        [128360] = 1339,        -- Thicketman Spectre Mask
        [133550] = 4660,        -- Clockwork Curator
        [134678] = 4797,        -- Jester's Scintillator
        [137962] = 149,         -- Stonefire Scamp
        [137963] = 161,         -- Soul-Shriven
        [138784] = 5019,        -- Arena Gladiator Helm
        [139464] = 4996,        -- Big-Eared Ginger Kitten
        [139465] = 5047,        -- Psijic Glowglobe
        [140308] = 5454,        -- Molag Kena Mask
        [140309] = 5455,        -- Molag Kena's Shoulder
        [140310] = 5457,        -- Shadowrend's Shoulder
        [140311] = 5456,        -- Shadowrend Mask
        [140312] = 5453,        -- Ilambris' Shoulder
        [140313] = 5452,        -- Ilambris Mask
        [140314] = 5355,        -- Fanged Worm Jerkin
        [140315] = 5356,        -- Fanged Worm Hat
        [140316] = 5357,        -- Fanged Worm Breeches
        [140317] = 5358,        -- Fanged Worm Epaulets
        [140318] = 5359,        -- Fanged Worm Shoes
        [140319] = 5360,        -- Fanged Worm Gloves
        [140320] = 5361,        -- Fanged Worm Robe
        [140321] = 5362,        -- Fanged Worm Sash
        [140322] = 5363,        -- Fanged Worm Jack
        [140323] = 5364,        -- Fanged Worm Helmet
        [140324] = 5365,        -- Fanged Worm Guards
        [140325] = 5366,        -- Fanged Worm Arm Cops
        [140326] = 5367,        -- Fanged Worm Boots
        [140327] = 5368,        -- Fanged Worm Bracers
        [140328] = 5369,        -- Fanged Worm Belt
        [140329] = 5370,        -- Fanged Worm Cuirass
        [140330] = 5371,        -- Fanged Worm Helm
        [140331] = 5372,        -- Fanged Worm Greaves
        [140332] = 5373,        -- Fanged Worm Pauldrons
        [140333] = 5374,        -- Fanged Worm Sabatons
        [140334] = 5375,        -- Fanged Worm Gauntlets
        [140335] = 5376,        -- Fanged Worm Girdle
        [140336] = 5378,        -- Fanged Worm Battle Axe
        [140337] = 5379,        -- Fanged Worm Maul
        [140338] = 5380,        -- Fanged Worm Greatsword
        [140339] = 5381,        -- Fanged Worm Axe
        [140340] = 5382,        -- Fanged Worm Bow
        [140341] = 5383,        -- Fanged Worm Dagger
        [140342] = 5384,        -- Fanged Worm Mace
        [140343] = 5385,        -- Fanged Worm Shield
        [140344] = 5386,        -- Fanged Worm Staff
        [140345] = 5387,        -- Fanged Worm Sword
        [140346] = 5420,        -- Horned Dragon Battle Axe
        [140347] = 5421,        -- Horned Dragon Maul
        [140348] = 5422,        -- Horned Dragon Greatsword
        [140349] = 5423,        -- Horned Dragon Axe
        [140350] = 5424,        -- Horned Dragon Bow
        [140351] = 5425,        -- Horned Dragon Dagger
        [140352] = 5426,        -- Horned Dragon Mace
        [140353] = 5427,        -- Horned Dragon Shield
        [140354] = 5428,        -- Horned Dragon Staff
        [140355] = 5429,        -- Horned Dragon Sword
        [140356] = 5430,        -- Horned Dragon Jerkin
        [140357] = 5431,        -- Horned Dragon Hat
        [140358] = 5432,        -- Horned Dragon Breeches
        [140359] = 5433,        -- Horned Dragon Epaulets
        [140360] = 5434,        -- Horned Dragon Shoes
        [140361] = 5435,        -- Horned Dragon Gloves
        [140362] = 5436,        -- Horned Dragon Robe
        [140363] = 5437,        -- Horned Dragon Sash
        [140364] = 5438,        -- Horned Dragon Helmet
        [140365] = 5439,        -- Horned Dragon Jack
        [140366] = 5440,        -- Horned Dragon Guards
        [140367] = 5441,        -- Horned Dragon Arm Cops
        [140368] = 5442,        -- Horned Dragon Boots
        [140369] = 5443,        -- Horned Dragon Bracers
        [140370] = 5444,        -- Horned Dragon Belt
        [140371] = 5445,        -- Horned Dragon Cuirass
        [140372] = 5446,        -- Horned Dragon Helm
        [140373] = 5447,        -- Horned Dragon Greaves
        [140374] = 5448,        -- Horned Dragon Pauldrons
        [140375] = 5449,        -- Horned Dragon Sabatons
        [140376] = 5450,        -- Horned Dragon Gauntlets
        [140377] = 5451,        -- Horned Dragon Girdle
        [141749] = 5656,        -- Swamp Jelly
        [141750] = 5589,        -- Arena Gladiator
        [141915] = 5590,        -- Apple-Bobbing Cauldron
        [141977] = 5621,        -- Pit Daemon Cuirass
        [141978] = 5622,        -- Pit Daemon Helm
        [141979] = 5623,        -- Pit Daemon Greaves
        [141980] = 5624,        -- Pit Daemon Pauldrons
        [141981] = 5625,        -- Pit Daemon Sabatons
        [141982] = 5626,        -- Pit Daemon Gauntlets
        [141983] = 5627,        -- Pit Daemon Girdle
        [141984] = 5628,        -- Stormlord Cuirass
        [141985] = 5629,        -- Stormlord Helm
        [141986] = 5630,        -- Stormlord Greaves
        [141987] = 5631,        -- Stormlord Pauldrons
        [141988] = 5632,        -- Stormlord Sabatons
        [141989] = 5633,        -- Stormlord Gauntlets
        [141990] = 5634,        -- Stormlord Girdle
        [141991] = 5645,        -- Firedrake Cuirass
        [141992] = 5646,        -- Firedrake Helm
        [141993] = 5647,        -- Firedrake Greaves
        [141994] = 5648,        -- Firedrake Pauldrons
        [141995] = 5649,        -- Firedrake Sabatons
        [141996] = 5650,        -- Firedrake Gauntlets
        [141997] = 5651,        -- Firedrake Girdle
        [142010] = 5615,        -- Iceheart Mask
        [142011] = 5616,        -- Iceheart's Shoulder
        [142012] = 5546,        -- Grothdarr's Shoulder
        [142013] = 5545,        -- Grothdarr Mask
        [142014] = 5608,        -- Troll King's Shoulder
        [142015] = 5607,        -- Troll King Mask
        [146038] = 5924,        -- Bloodspawn Mask
        [146040] = 5925,        -- Bloodspawn's Shoulder
        [146041] = 5746,        -- Gladiator Taunt
        [146043] = 5763,        -- Sellistrix Mask
        [146044] = 5764,        -- Sellistrix's Shoulder
        [146045] = 5926,        -- Swarm Mother Mask
        [146046] = 5927,        -- Swarm Mother's Shoulder
        [146074] = 6045,        -- Engine Guardian's Shoulder
        [146075] = 6044,        -- Engine Guardian Mask
        [147286] = 6064,        -- Elinhir Arena Lion
        [147301] = 6141,        -- Prophet's Hood
        [147302] = 6143,        -- Prophet's Sandals
        [147303] = 6144,        -- Prophet's Wraps
        [147304] = 6145,        -- Prophet's Robe
        [147305] = 6142,        -- Prophet's Shawl
        [147306] = 6146,        -- Prophet's Staff
        [147307] = 6155,        -- Lyris Titanborn's Cuirass
        [147309] = 6153,        -- Lyris Titanborn's Greaves
        [147310] = 6152,        -- Lyris Titanborn's Pauldrons
        [147311] = 6151,        -- Lyris Titanborn's Sabatons
        [147312] = 6150,        -- Lyris Titanborn's Gauntlets
        [147313] = 6149,        -- Lyris Titanborn's Girdle
        [147314] = 6148,        -- Lyris Titanborn's Battle Axe
        [147315] = 6147,        -- Lyris Titanborn's Shield
        [147316] = 6157,        -- Sai Sahan's Jack
        [147317] = 6158,        -- Sai Sahan's Guards
        [147318] = 6159,        -- Sai Sahan's Arm Cops
        [147319] = 6160,        -- Sai Sahan's Boots
        [147320] = 6161,        -- Sai Sahan's Bracers
        [147321] = 6162,        -- Sai Sahan's Belt
        [147322] = 6163,        -- Sai Sahan's Greatsword
        [147323] = 6164,        -- Sai Sahan's Sword
        [147324] = 6165,        -- Abnur Tharn's Jerkin
        [147326] = 6167,        -- Abnur Tharn's Breeches
        [147327] = 6168,        -- Abnur Tharn's Epaulets
        [147328] = 6169,        -- Abnur Tharn's Shoes
        [147329] = 6170,        -- Abnur Tharn's Gloves
        [147330] = 6171,        -- Abnur Tharn's Sash
        [147331] = 6172,        -- Abnur Tharn's Dagger
        [147332] = 6173,        -- Abnur Tharn's Staff
        [147333] = 6141,        -- Prophet's Hood
        [147334] = 6143,        -- Prophet's Sandals
        [147335] = 6144,        -- Prophet's Wraps
        [147336] = 6145,        -- Prophet's Robe
        [147337] = 6142,        -- Prophet's Shawl
        [147338] = 6146,        -- Prophet's Staff
        [147339] = 6155,        -- Lyris Titanborn's Cuirass
        [147341] = 6153,        -- Lyris Titanborn's Greaves
        [147342] = 6152,        -- Lyris Titanborn's Pauldrons
        [147343] = 6151,        -- Lyris Titanborn's Sabatons
        [147344] = 6150,        -- Lyris Titanborn's Gauntlets
        [147345] = 6149,        -- Lyris Titanborn's Girdle
        [147346] = 6148,        -- Lyris Titanborn's Battle Axe
        [147347] = 6147,        -- Lyris Titanborn's Shield
        [147348] = 6157,        -- Sai Sahan's Jack
        [147349] = 6158,        -- Sai Sahan's Guards
        [147350] = 6159,        -- Sai Sahan's Arm Cops
        [147351] = 6160,        -- Sai Sahan's Boots
        [147352] = 6161,        -- Sai Sahan's Bracers
        [147353] = 6162,        -- Sai Sahan's Belt
        [147354] = 6163,        -- Sai Sahan's Greatsword
        [147355] = 6164,        -- Sai Sahan's Sword
        [147356] = 6165,        -- Abnur Tharn's Jerkin
        [147358] = 6167,        -- Abnur Tharn's Breeches
        [147359] = 6168,        -- Abnur Tharn's Epaulets
        [147360] = 6169,        -- Abnur Tharn's Shoes
        [147361] = 6170,        -- Abnur Tharn's Gloves
        [147362] = 6171,        -- Abnur Tharn's Sash
        [147363] = 6172,        -- Abnur Tharn's Dagger
        [147364] = 6173,        -- Abnur Tharn's Staff
        [147428] = 6174,        -- Valkyn Skoria Mask
        [147429] = 6175,        -- Valkyn Skoria's Shoulder
        [147467] = 6097,        -- Cadwell's "Battle Axe"
        [147468] = 6098,        -- Cadwell's "Maul"
        [147469] = 6099,        -- Cadwell's "Greatsword"
        [147470] = 6100,        -- Cadwell's "Axe"
        [147471] = 6101,        -- Cadwell's "Bow"
        [147472] = 6102,        -- Cadwell's "Dagger"
        [147473] = 6103,        -- Cadwell's "Mace"
        [147474] = 6104,        -- Cadwell's "Shield"
        [147475] = 6105,        -- Cadwell's "Staff"
        [147476] = 6106,        -- Cadwell's "Sword"
        [147478] = 6097,        -- Cadwell's "Battle Axe"
        [147479] = 6098,        -- Cadwell's "Maul"
        [147480] = 6099,        -- Cadwell's "Greatsword"
        [147481] = 6100,        -- Cadwell's "Axe"
        [147482] = 6101,        -- Cadwell's "Bow"
        [147483] = 6102,        -- Cadwell's "Dagger"
        [147484] = 6103,        -- Cadwell's "Mace"
        [147485] = 6104,        -- Cadwell's "Shield"
        [147486] = 6105,        -- Cadwell's "Staff"
        [147487] = 6106,        -- Cadwell's "Sword"
        [147499] = 6197,        -- Guar Stomp
        [147534] = 6229,        -- Pit Daemon Battle Axe
        [147535] = 6230,        -- Pit Daemon Maul
        [147536] = 6231,        -- Pit Daemon Greatsword
        [147537] = 6232,        -- Pit Daemon Axe
        [147538] = 6233,        -- Pit Daemon Bow
        [147539] = 6234,        -- Pit Daemon Dagger
        [147540] = 6235,        -- Pit Daemon Mace
        [147541] = 6236,        -- Pit Daemon Shield
        [147542] = 6237,        -- Pit Daemon Staff
        [147543] = 6238,        -- Pit Daemon Sword
        [147544] = 6209,        -- Stormlord Battle Axe
        [147545] = 6210,        -- Stormlord Maul
        [147546] = 6211,        -- Stormlord Greatsword
        [147547] = 6212,        -- Stormlord Axe
        [147548] = 6213,        -- Stormlord Bow
        [147549] = 6214,        -- Stormlord Dagger
        [147550] = 6215,        -- Stormlord Mace
        [147551] = 6216,        -- Stormlord Shield
        [147552] = 6217,        -- Stormlord Staff
        [147553] = 6218,        -- Stormlord Sword
        [147554] = 6219,        -- Firedrake Battle Axe
        [147555] = 6220,        -- Firedrake Maul
        [147556] = 6221,        -- Firedrake Greatsword
        [147557] = 6222,        -- Firedrake Axe
        [147558] = 6223,        -- Firedrake Bow
        [147559] = 6224,        -- Firedrake Dagger
        [147560] = 6225,        -- Firedrake Mace
        [147561] = 6226,        -- Firedrake Shield
        [147562] = 6227,        -- Firedrake Staff
        [147563] = 6228,        -- Firedrake Sword
        [147601] = 6251,        -- Nightflame Mask
        [147602] = 6252,        -- Nightflame's Shoulder
        [147660] = 6295,        -- Prophet's Breeches
        [147661] = 6295,        -- Prophet's Breeches
        [147767] = 6388,        -- Lord Warden Mask
        [147768] = 6389,        -- Lord Warden's Shoulder
        [151561] = 5463,        -- Shadowrend Greatsword
        [151562] = 5464,        -- Shadowrend Bow
        [151563] = 5465,        -- Shadowrend Shield
        [151564] = 5466,        -- Shadowrend Staff
        [151565] = 5467,        -- Shadowrend Axe
        [151566] = 5162,        -- Ilambris Battle Axe
        [151567] = 5163,        -- Ilambris Bow
        [151568] = 5164,        -- Ilambris Shield
        [151569] = 5165,        -- Ilambris Staff
        [151570] = 5166,        -- Ilambris Sword
        [151571] = 5118,        -- Molag Kena Sword
        [151572] = 5123,        -- Molag Kena Maul
        [151573] = 5124,        -- Molag Kena Shield
        [151574] = 5125,        -- Molag Kena Bow
        [151575] = 5126,        -- Molag Kena Staff
        [151576] = 5191,        -- Grothdarr Mace
        [151577] = 5192,        -- Grothdarr Staff
        [151578] = 5193,        -- Grothdarr Maul
        [151579] = 5194,        -- Grothdarr Bow
        [151580] = 5195,        -- Grothdarr Shield
        [151581] = 5456,        -- Shadowrend Mask
        [151582] = 5457,        -- Shadowrend's Shoulder
        [151583] = 5452,        -- Ilambris Mask
        [151584] = 5453,        -- Ilambris' Shoulder
        [151585] = 5454,        -- Molag Kena Mask
        [151586] = 5455,        -- Molag Kena's Shoulder
        [151587] = 5545,        -- Grothdarr Mask
        [151588] = 5546,        -- Grothdarr's Shoulder
        [151916] = 6586,        -- Second Legion Jack
        [151917] = 6587,        -- Second Legion Helmet
        [151918] = 6588,        -- Second Legion Arm Cops
        [151919] = 6589,        -- Second Legion Guards
        [151920] = 6590,        -- Second Legion Belt
        [151921] = 6591,        -- Second Legion Bracers
        [151922] = 6592,        -- Second Legion Boots
        [151923] = 6586,        -- Second Legion Jack
        [151924] = 6587,        -- Second Legion Helmet
        [151925] = 6588,        -- Second Legion Arm Cops
        [151926] = 6589,        -- Second Legion Guards
        [151927] = 6590,        -- Second Legion Belt
        [151928] = 6591,        -- Second Legion Bracers
        [151929] = 6592,        -- Second Legion Boots
        [151931] = 6493,        -- Aldmeri Dominion Banner
        [151932] = 6365,        -- Daggerfall Covenant Banner
        [151933] = 6494,        -- Ebonheart Pact Banner
        [151940] = 6438,        -- Siegemaster Close Helm
        [152121] = 3720,        -- the Maelstrom's Battle Axe
        [152122] = 3721,        -- the Maelstrom's Maul
        [152123] = 3722,        -- the Maelstrom's Greatsword
        [152124] = 3723,        -- the Maelstrom's Axe
        [152125] = 3724,        -- the Maelstrom's Bow
        [152126] = 3725,        -- the Maelstrom's Mace
        [152127] = 3726,        -- the Maelstrom's Shield
        [152128] = 3727,        -- the Maelstrom's Staff
        [152129] = 3728,        -- the Maelstrom's Sword
        [152130] = 4892,        -- the Maelstrom's Dagger
        [152131] = 3720,        -- the Maelstrom's Battle Axe
        [152132] = 3721,        -- the Maelstrom's Maul
        [152133] = 3722,        -- the Maelstrom's Greatsword
        [152134] = 3723,        -- the Maelstrom's Axe
        [152135] = 3724,        -- the Maelstrom's Bow
        [152136] = 3725,        -- the Maelstrom's Mace
        [152137] = 3726,        -- the Maelstrom's Shield
        [152138] = 3727,        -- the Maelstrom's Staff
        [152139] = 3728,        -- the Maelstrom's Sword
        [152140] = 4892,        -- the Maelstrom's Dagger
        [152252] = 6690,        -- Mighty Chudan Mask
        [152253] = 6691,        -- Mighty Chudan's Shoulder
        [152254] = 6693,        -- Velidreth's Shoulder
        [152255] = 6692,        -- Velidreth Mask
        [153475] = 6721,        -- Pirate Skeleton Mask
        [153476] = 6722,        -- Pirate Skeleton's Shoulder
        [153493] = 6728,        -- Battleground Runner Jack
        [153494] = 6733,        -- Battleground Runner Bracers
        [153495] = 6730,        -- Battleground Runner Guards
        [153496] = 6732,        -- Battleground Runner Boots
        [153497] = 6731,        -- Battleground Runner Arm Cops
        [153498] = 6729,        -- Battleground Runner Helmet
        [153499] = 6744,        -- Chokethorn Mask
        [153500] = 6745,        -- Chokethorn's Shoulder
        [153537] = 6665,        -- Siegemaster's Uniform
        [153564] = 6753,        -- Glenmoril Wyrd Battle Axe
        [153565] = 6754,        -- Glenmoril Wyrd Maul
        [153566] = 6755,        -- Glenmoril Wyrd Greatsword
        [153567] = 6756,        -- Glenmoril Wyrd Axe
        [153568] = 6757,        -- Glenmoril Wyrd Bow
        [153569] = 6758,        -- Glenmoril Wyrd Dagger
        [153570] = 6759,        -- Glenmoril Wyrd Mace
        [153571] = 6760,        -- Glenmoril Wyrd Shield
        [153572] = 6761,        -- Glenmoril Wyrd Staff
        [153573] = 6762,        -- Glenmoril Wyrd Sword
        [153574] = 6753,        -- Glenmoril Wyrd Battle Axe
        [153575] = 6754,        -- Glenmoril Wyrd Maul
        [153576] = 6755,        -- Glenmoril Wyrd Greatsword
        [153577] = 6756,        -- Glenmoril Wyrd Axe
        [153578] = 6757,        -- Glenmoril Wyrd Bow
        [153579] = 6758,        -- Glenmoril Wyrd Dagger
        [153580] = 6759,        -- Glenmoril Wyrd Mace
        [153581] = 6760,        -- Glenmoril Wyrd Shield
        [153582] = 6761,        -- Glenmoril Wyrd Staff
        [153583] = 6762,        -- Glenmoril Wyrd Sword
        [153619] = 6775,        -- Spawn of Mephala Mask
        [153620] = 6776,        -- Spawn of Mephala's Shoulder
        [153740] = 6911,        -- Opal Ilambris' Shoulder
        [153741] = 6910,        -- Opal Ilambris Mask
        [153742] = 6913,        -- Opal Troll King's Shoulder
        [153743] = 6912,        -- Opal Troll King Mask
        [153744] = 6906,        -- Opal Bloodspawn Mask
        [153745] = 6907,        -- Opal Bloodspawn's Shoulder
        [153746] = 6909,        -- Opal Engine Guardian's Shoulder
        [153747] = 6908,        -- Opal Engine Guardian Mask
        [153776] = 6787,        -- Glenmoril Wyrd Jerkin
        [153777] = 6788,        -- Glenmoril Wyrd Hat
        [153778] = 6789,        -- Glenmoril Wyrd Breeches
        [153779] = 6790,        -- Glenmoril Wyrd Epaulets
        [153780] = 6791,        -- Glenmoril Wyrd Sash
        [153781] = 6792,        -- Glenmoril Wyrd Shoes
        [153782] = 6793,        -- Glenmoril Wyrd Gloves
        [153783] = 6794,        -- Glenmoril Wyrd Robe
        [153784] = 6787,        -- Glenmoril Wyrd Jerkin
        [153785] = 6788,        -- Glenmoril Wyrd Hat
        [153786] = 6789,        -- Glenmoril Wyrd Breeches
        [153787] = 6790,        -- Glenmoril Wyrd Epaulets
        [153788] = 6791,        -- Glenmoril Wyrd Sash
        [153789] = 6792,        -- Glenmoril Wyrd Shoes
        [153790] = 6793,        -- Glenmoril Wyrd Gloves
        [153791] = 6794,        -- Glenmoril Wyrd Robe
        [153883] = 6949,        -- Infernal Guardian Shoulder
        [153884] = 6948,        -- Infernal Guardian Mask
        [153885] = 6957,        -- Kra'gh Shoulder
        [153886] = 6956,        -- Kra'gh Mask
        [154834] = 6964,        -- Sentinel of Rkugamz Shoulder
        [154835] = 6963,        -- Sentinel of Rkugamz Mask
        [156626] = 1338,        -- Hollowjack Spectre Mask
        [156672] = 6786,        -- Battleground Runner Waster
        [156673] = 6785,        -- Battleground Runner Staff
        [156674] = 6783,        -- Battleground Runner Bow
        [156675] = 6782,        -- Battleground Runner Bludgeon
        [156676] = 6784,        -- Battleground Runner Shield
        [156681] = 7300,        -- Skaal Explorer Battle Axe
        [156682] = 7301,        -- Skaal Explorer Maul
        [156683] = 7302,        -- Skaal Explorer Greatsword
        [156684] = 7303,        -- Skaal Explorer Axe
        [156685] = 7304,        -- Skaal Explorer Bow
        [156686] = 7305,        -- Skaal Explorer Mace
        [156687] = 7306,        -- Skaal Explorer Shield
        [156688] = 7307,        -- Skaal Explorer Staff
        [156689] = 7308,        -- Skaal Explorer Sword
        [156690] = 7309,        -- Skaal Explorer Dagger
        [156691] = 7299,        -- Skaal Explorer Sash
        [156692] = 7293,        -- Skaal Explorer Jerkin
        [156693] = 7294,        -- Skaal Explorer Hat
        [156694] = 7295,        -- Skaal Explorer Breeches
        [156695] = 7296,        -- Skaal Explorer Epaulets
        [156696] = 7297,        -- Skaal Explorer Shoes
        [156697] = 7298,        -- Skaal Explorer Gloves
        [156698] = 7300,        -- Skaal Explorer Battle Axe
        [156699] = 7301,        -- Skaal Explorer Maul
        [156700] = 7302,        -- Skaal Explorer Greatsword
        [156701] = 7303,        -- Skaal Explorer Axe
        [156702] = 7304,        -- Skaal Explorer Bow
        [156703] = 7305,        -- Skaal Explorer Mace
        [156704] = 7306,        -- Skaal Explorer Shield
        [156705] = 7307,        -- Skaal Explorer Staff
        [156706] = 7308,        -- Skaal Explorer Sword
        [156707] = 7309,        -- Skaal Explorer Dagger
        [156708] = 7299,        -- Skaal Explorer Sash
        [156709] = 7293,        -- Skaal Explorer Jerkin
        [156710] = 7294,        -- Skaal Explorer Hat
        [156711] = 7295,        -- Skaal Explorer Breeches
        [156712] = 7296,        -- Skaal Explorer Epaulets
        [156713] = 7297,        -- Skaal Explorer Shoes
        [156714] = 7298,        -- Skaal Explorer Gloves
        [156718] = 6911,        -- Opal Ilambris' Shoulder
        [156719] = 6910,        -- Opal Ilambris Mask
        [156720] = 6913,        -- Opal Troll King's Shoulder
        [156721] = 6912,        -- Opal Troll King Mask
        [156722] = 6906,        -- Opal Bloodspawn Mask
        [156723] = 6907,        -- Opal Bloodspawn's Shoulder
        [156724] = 6909,        -- Opal Engine Guardian's Shoulder
        [156725] = 6908,        -- Opal Engine Guardian Mask
        [156726] = 6814,        -- Opal Ilambris Battle Axe
        [156727] = 6815,        -- Opal Ilambris Bow
        [156728] = 6816,        -- Opal Ilambris Shield
        [156729] = 6817,        -- Opal Ilambris Staff
        [156730] = 6818,        -- Opal Ilambris Sword
        [156737] = 6819,        -- Opal Engine Guardian Dagger
        [156738] = 6820,        -- Opal Engine Guardian Staff
        [156739] = 6821,        -- Opal Engine Guardian Greatsword
        [156740] = 6822,        -- Opal Engine Guardian Bow
        [156741] = 6823,        -- Opal Engine Guardian Shield
        [156742] = 6824,        -- Opal Bloodspawn Battle Axe
        [156743] = 6825,        -- Opal Bloodspawn Bow
        [156744] = 6826,        -- Opal Bloodspawn Shield
        [156745] = 6827,        -- Opal Bloodspawn Staff
        [156746] = 6828,        -- Opal Bloodspawn Mace
        [156747] = 6829,        -- Opal Troll King Axe
        [156748] = 6830,        -- Opal Troll King Staff
        [156749] = 6831,        -- Opal Troll King Battle Axe
        [156750] = 6832,        -- Opal Troll King Bow
        [156751] = 6833,        -- Opal Troll King Shield
        [156781] = 7310,        -- Legion Zero Cuirass
        [156782] = 7311,        -- Legion Zero Helm
        [156783] = 7312,        -- Legion Zero Greaves
        [156784] = 7313,        -- Legion Zero Pauldrons
        [156785] = 7314,        -- Legion Zero Sabatons
        [156786] = 7315,        -- Legion Zero Gauntlets
        [156787] = 7316,        -- Legion Zero Girdle
        [156788] = 7310,        -- Legion Zero Cuirass
        [156789] = 7311,        -- Legion Zero Helm
        [156790] = 7312,        -- Legion Zero Greaves
        [156791] = 7313,        -- Legion Zero Pauldrons
        [156792] = 7314,        -- Legion Zero Sabatons
        [156793] = 7315,        -- Legion Zero Gauntlets
        [156794] = 7316,        -- Legion Zero Girdle
        [156811] = 6814,        -- Opal Ilambris Battle Axe
        [156812] = 6815,        -- Opal Ilambris Bow
        [156813] = 6816,        -- Opal Ilambris Shield
        [156814] = 6817,        -- Opal Ilambris Staff
        [156815] = 6818,        -- Opal Ilambris Sword
        [156816] = 6819,        -- Opal Engine Guardian Dagger
        [156817] = 6820,        -- Opal Engine Guardian Staff
        [156818] = 6821,        -- Opal Engine Guardian Greatsword
        [156819] = 6822,        -- Opal Engine Guardian Bow
        [156820] = 6823,        -- Opal Engine Guardian Shield
        [156821] = 6824,        -- Opal Bloodspawn Battle Axe
        [156822] = 6825,        -- Opal Bloodspawn Bow
        [156823] = 6826,        -- Opal Bloodspawn Shield
        [156824] = 6827,        -- Opal Bloodspawn Staff
        [156825] = 6828,        -- Opal Bloodspawn Mace
        [156826] = 6829,        -- Opal Troll King Axe
        [156827] = 6830,        -- Opal Troll King Staff
        [156828] = 6831,        -- Opal Troll King Battle Axe
        [156829] = 6832,        -- Opal Troll King Bow
        [156830] = 6833,        -- Opal Troll King Shield
        [156835] = 7330,        -- Slimecraw's Shoulder
        [156836] = 7329,        -- Slimecraw Mask
        [156837] = 7425,        -- Stormfist Shoulder
        [156838] = 7424,        -- Stormfist Mask
        [156839] = 7331,        -- Jephrine Paladin Cuirass
        [156840] = 7338,        -- Knight of the Circle Cuirass
        [156841] = 7339,        -- Knight of the Circle Helm
        [159472] = 7332,        -- Jephrine Paladin Helm
        [159473] = 7333,        -- Jephrine Paladin Greaves
        [159474] = 7334,        -- Jephrine Paladin Pauldrons
        [159475] = 7335,        -- Jephrine Paladin Sabatons
        [159476] = 7336,        -- Jephrine Paladin Gauntlets
        [159477] = 7337,        -- Jephrine Paladin Girdle
        [159478] = 7375,        -- Jephrine Paladin Greatsword
        [159479] = 7376,        -- Jephrine Paladin Bow
        [159480] = 7377,        -- Jephrine Paladin Shield
        [159481] = 7378,        -- Jephrine Paladin Staff
        [159482] = 7379,        -- Jephrine Paladin Sword
        [159483] = 7331,        -- Jephrine Paladin Cuirass
        [159484] = 7332,        -- Jephrine Paladin Helm
        [159485] = 7333,        -- Jephrine Paladin Greaves
        [159486] = 7334,        -- Jephrine Paladin Pauldrons
        [159487] = 7335,        -- Jephrine Paladin Sabatons
        [159488] = 7336,        -- Jephrine Paladin Gauntlets
        [159489] = 7337,        -- Jephrine Paladin Girdle
        [159490] = 7375,        -- Jephrine Paladin Greatsword
        [159491] = 7376,        -- Jephrine Paladin Bow
        [159492] = 7377,        -- Jephrine Paladin Shield
        [159493] = 7378,        -- Jephrine Paladin Staff
        [159494] = 7379,        -- Jephrine Paladin Sword
        [159505] = 7340,        -- Knight of the Circle Greaves
        [159506] = 7341,        -- Knight of the Circle Pauldrons
        [159507] = 7342,        -- Knight of the Circle Sabatons
        [159508] = 7343,        -- Knight of the Circle Gauntlets
        [159509] = 7380,        -- Knight of the Circle Maul
        [159510] = 7381,        -- Knight of the Circle Bow
        [159511] = 7382,        -- Knight of the Circle Shield
        [159512] = 7383,        -- Knight of the Circle Staff
        [159513] = 7384,        -- Knight of the Circle Sword
        [159574] = 7426,        -- Balorgh Mask
        [159575] = 7427,        -- Balorgh Shoulder
        [159691] = 7683,        -- Scourge Harvester Shoulder
        [159692] = 7682,        -- Scourge Harvester Mask
        [160516] = 7750,        -- Domihaus Shoulder
        [160517] = 7749,        -- Domihaus Mask
        [160518] = 7757,        -- Opal Iceheart's Shoulder
        [160519] = 7756,        -- Opal Iceheart Mask
        [160520] = 7764,        -- Opal Lord Warden's Shoulder
        [160521] = 7763,        -- Opal Lord Warden Mask
        [160522] = 7771,        -- Opal Nightflame's Shoulder
        [160523] = 7770,        -- Opal Nightflame Mask
        [160526] = 7785,        -- Nerien'eth's Shoulder
        [160527] = 7784,        -- Nerien'eth Mask
        [160537] = 7809,        -- Opal Swarm Mother's Shoulder
        [160538] = 7808,        -- Opal Swarm Mother Mask
        [165900] = 8116,        -- Snowhawk Mage Jerkin
        [165901] = 8117,        -- Snowhawk Mage Hat
        [165902] = 8118,        -- Snowhawk Mage Breeches
        [165903] = 8119,        -- Snowhawk Mage Epaulets
        [165904] = 8120,        -- Snowhawk Mage Shoes
        [165905] = 8121,        -- Snowhawk Mage Gloves
        [165906] = 8123,        -- Snowhawk Mage Robe
        [165907] = 8122,        -- Snowhawk Mage Sash
        [165947] = 8081,        -- Chitinous Jack
        [165948] = 8082,        -- Chitinous Helmet
        [165949] = 8083,        -- Chitinous Guards
        [165950] = 8084,        -- Chitinous Arm Cops
        [165951] = 8085,        -- Chitinous Boots
        [165952] = 8086,        -- Chitinous Bracers
        [165953] = 8087,        -- Chitinous Belt
        [165954] = 8116,        -- Snowhawk Mage Jerkin
        [165955] = 8117,        -- Snowhawk Mage Hat
        [165956] = 8118,        -- Snowhawk Mage Breeches
        [165957] = 8119,        -- Snowhawk Mage Epaulets
        [165958] = 8120,        -- Snowhawk Mage Shoes
        [165959] = 8121,        -- Snowhawk Mage Gloves
        [165960] = 8123,        -- Snowhawk Mage Robe
        [165961] = 8122,        -- Snowhawk Mage Sash
        [165962] = 8099,        -- Chitinous Battle Axe
        [165963] = 8104,        -- Chitinous Maul
        [165964] = 8105,        -- Chitinous Greatsword
        [165965] = 8103,        -- Chitinous Axe
        [165966] = 8100,        -- Chitinous Bow
        [165967] = 8106,        -- Chitinous Dagger
        [165968] = 8107,        -- Chitinous Mace
        [165969] = 8101,        -- Chitinous Shield
        [165970] = 8102,        -- Chitinous Staff
        [165971] = 8108,        -- Chitinous Sword
        [166468] = 7595,        -- Reach-Mage Ceremonial Skullcap
        [166479] = 8148,        -- Maw of the Infernal's Shoulder
        [166480] = 8147,        -- Maw of the Infernal Mask
        [166962] = 8168,        -- Earthgore's Shoulder
        [166963] = 8167,        -- Earthgore Mask
        [166967] = 8177,        -- Tremorscale's Shoulder
        [166968] = 8176,        -- Tremorscale Mask
        [167008] = 8340,        -- Selene Shoulder
        [167009] = 8339,        -- Selene Mask
        [167019] = 8356,        -- Legion Zero Vigiles Jack
        [167020] = 8357,        -- Legion Zero Vigiles Helmet
        [167021] = 8358,        -- Legion Zero Vigiles Guards
        [167022] = 8359,        -- Legion Zero Vigiles Arm Cops
        [167023] = 8360,        -- Legion Zero Vigiles Boots
        [167024] = 8361,        -- Legion Zero Vigiles Bracers
        [167025] = 8362,        -- Legion Zero Vigiles Belt
        [167026] = 8356,        -- Legion Zero Vigiles Jack
        [167027] = 8357,        -- Legion Zero Vigiles Helmet
        [167028] = 8358,        -- Legion Zero Vigiles Guards
        [167029] = 8359,        -- Legion Zero Vigiles Arm Cops
        [167030] = 8360,        -- Legion Zero Vigiles Boots
        [167031] = 8361,        -- Legion Zero Vigiles Bracers
        [167032] = 8362,        -- Legion Zero Vigiles Belt
        [167033] = 8343,        -- Tools of Domination Battle Axe
        [167034] = 8343,        -- Tools of Domination Battle Axe
        -- [167084] = ?,        -- Stone Husk Mask
        -- [167085] = ?,        -- Stone Husk's Shoul
        [167093] = 8344,        -- Tools of Domination Bow
        [167094] = 8344,        -- Tools of Domination Bow
        [167095] = 8345,        -- Tools of Domination Shield
        [167096] = 8345,        -- Tools of Domination Shield
        [167097] = 8346,        -- Tools of Domination Staff
        [167098] = 8346,        -- Tools of Domination Staff
        [167099] = 8347,        -- Tools of Domination Axe
        [167100] = 8347,        -- Tools of Domination Axe
        [167101] = 8348,        -- Tools of Domination Maul
        [167102] = 8348,        -- Tools of Domination Maul
        [167103] = 8349,        -- Tools of Domination Greatsword
        [167104] = 8349,        -- Tools of Domination Greatsword
        [167105] = 8350,        -- Tools of Domination Mace
        [167106] = 8350,        -- Tools of Domination Mace
        [167107] = 8351,        -- Tools of Domination Sword
        [167108] = 8351,        -- Tools of Domination Sword
        [167109] = 8352,        -- Tools of Domination Dagger
        [167110] = 8352,        -- Tools of Domination Dagger
        -- [167160] = ?,        -- Lady Thorn's Mask
        -- [167161] = ?,        -- Lady Thorn's Shoulder
        [167212] = 8367,        -- Sovngarde Stalwart Jack
        [167213] = 8368,        -- Sovngarde Stalwart Helmet
        [167214] = 8369,        -- Sovngarde Stalwart Guards
        [167215] = 8370,        -- Sovngarde Stalwart Arm Cops
        [167216] = 8371,        -- Sovngarde Stalwart Boots
        [167217] = 8372,        -- Sovngarde Stalwart Bracers
        [167218] = 8373,        -- Sovngarde Stalwart Belt
        [167219] = 8367,        -- Sovngarde Stalwart Jack
        [167220] = 8368,        -- Sovngarde Stalwart Helmet
        [167221] = 8369,        -- Sovngarde Stalwart Guards
        [167222] = 8370,        -- Sovngarde Stalwart Arm Cops
        [167223] = 8371,        -- Sovngarde Stalwart Boots
        [167224] = 8372,        -- Sovngarde Stalwart Bracers
        [167225] = 8373,        -- Sovngarde Stalwart Belt
        [167244] = 8324,        -- Grave Dancer Battle Axe
        [167245] = 8325,        -- Grave Dancer Bow
        [167246] = 8326,        -- Grave Dancer Shield
        [167247] = 8327,        -- Grave Dancer Staff
        [167248] = 8329,        -- Grave Dancer Maul
        [167249] = 8330,        -- Grave Dancer Greatsword
        [167250] = 8331,        -- Grave Dancer Mace
        [167251] = 8332,        -- Grave Dancer Sword
        [167252] = 8333,        -- Grave Dancer Dagger
        [167253] = 8324,        -- Grave Dancer Battle Axe
        [167254] = 8325,        -- Grave Dancer Bow
        [167255] = 8326,        -- Grave Dancer Shield
        [167256] = 8327,        -- Grave Dancer Staff
        [167257] = 8329,        -- Grave Dancer Maul
        [167258] = 8330,        -- Grave Dancer Greatsword
        [167259] = 8331,        -- Grave Dancer Mace
        [167260] = 8332,        -- Grave Dancer Sword
        [167261] = 8333,        -- Grave Dancer Dagger
        [167262] = 8328,        -- Grave Dancer Axe
        [167263] = 8328,        -- Grave Dancer Axe
        [167305] = 8043,        -- Timbercrow Wanderer
        [167937] = 439,         -- Pumpkin Spectre Mask
        [167938] = 440,         -- Scarecrow Spectre Mask
        [167939] = 1338,        -- Hollowjack Spectre Mask
        [167940] = 1339,        -- Thicketman Spectre Mask
        [169621] = 8689,        -- Vykosa Shoulder
        [169622] = 8688,        -- Vykosa Mask
        [170129] = 8696,        -- Thurvokun Shoulder
        [170130] = 8695,        -- Thurvokun Mask
        [170149] = 8730,        -- Rkindaleft Dwarven Battle Axe
        [170150] = 8731,        -- Rkindaleft Dwarven Bow
        [170151] = 8732,        -- Rkindaleft Dwarven Shield
        [170152] = 8733,        -- Rkindaleft Dwarven Staff
        [170153] = 8734,        -- Rkindaleft Dwarven Axe
        [170154] = 8735,        -- Rkindaleft Dwarven Maul
        [170155] = 8736,        -- Rkindaleft Dwarven Greatsword
        [170156] = 8737,        -- Rkindaleft Dwarven Mace
        [170157] = 8738,        -- Rkindaleft Dwarven Sword
        [170158] = 8739,        -- Rkindaleft Dwarven Dagger
        [170159] = 8730,        -- Rkindaleft Dwarven Battle Axe
        [170160] = 8731,        -- Rkindaleft Dwarven Bow
        [170161] = 8732,        -- Rkindaleft Dwarven Shield
        [170162] = 8733,        -- Rkindaleft Dwarven Staff
        [170163] = 8734,        -- Rkindaleft Dwarven Axe
        [170164] = 8735,        -- Rkindaleft Dwarven Maul
        [170165] = 8736,        -- Rkindaleft Dwarven Greatsword
        [170166] = 8737,        -- Rkindaleft Dwarven Mace
        [170167] = 8738,        -- Rkindaleft Dwarven Sword
        [170168] = 8739,        -- Rkindaleft Dwarven Dagger
        [170169] = 8762,        -- Zaan Shoulder
        [170170] = 8761,        -- Zaan Mask
        [170172] = 8749,        -- Ebonsteel Knight Cuirass
        [170173] = 8750,        -- Ebonsteel Knight Helm
        [170174] = 8751,        -- Ebonsteel Knight Greaves
        [170175] = 8752,        -- Ebonsteel Knight Pauldrons
        [170176] = 8753,        -- Ebonsteel Knight Sabatons
        [170177] = 8754,        -- Ebonsteel Knight Gauntlets
        [170178] = 8755,        -- Ebonsteel Knight Girdle
        [170182] = 8749,        -- Ebonsteel Knight Cuirass
        [170183] = 8750,        -- Ebonsteel Knight Helm
        [170184] = 8751,        -- Ebonsteel Knight Greaves
        [170185] = 8752,        -- Ebonsteel Knight Pauldrons
        [170186] = 8753,        -- Ebonsteel Knight Sabatons
        [170187] = 8754,        -- Ebonsteel Knight Gauntlets
        [170188] = 8755,        -- Ebonsteel Knight Girdle
        [170209] = 8674,        -- Doctrine Ordinator Jack
        [170210] = 8675,        -- Doctrine Ordinator Helm
        [170211] = 8676,        -- Doctrine Ordinator Guards
        [170212] = 8677,        -- Doctrine Ordinator Pauldrons
        [170213] = 8678,        -- Doctrine Ordinator Sabatons
        [170214] = 8679,        -- Doctrine Ordinator Gauntlets
        [170215] = 8680,        -- Doctrine Ordinator Girdle
        [170216] = 8674,        -- Doctrine Ordinator Jack
        [170217] = 8675,        -- Doctrine Ordinator Helm
        [170218] = 8676,        -- Doctrine Ordinator Guards
        [170219] = 8677,        -- Doctrine Ordinator Pauldrons
        [170220] = 8678,        -- Doctrine Ordinator Sabatons
        [170221] = 8679,        -- Doctrine Ordinator Gauntlets
        [170222] = 8680,        -- Doctrine Ordinator Girdle
        [170227] = 7756,        -- Opal Iceheart Mask
        [170228] = 7763,        -- Opal Lord Warden Mask
        [170229] = 7770,        -- Opal Nightflame Mask
        [170230] = 7808,        -- Opal Swarm Mother Mask
        [171266] = 7764,        -- Opal Lord Warden's Shoulder
        [171271] = 7751,        -- Opal Iceheart Greatsword
        [171272] = 7752,        -- Opal Iceheart Bow
        [171273] = 7753,        -- Opal Iceheart Shield
        [171274] = 7754,        -- Opal Iceheart Staff
        [171275] = 7755,        -- Opal Iceheart Sword
        [171276] = 7758,        -- Opal Lord Warden Greatsword
        [171277] = 7759,        -- Opal Lord Warden Bow
        [171278] = 7760,        -- Opal Lord Warden Shield
        [171279] = 7761,        -- Opal Lord Warden Staff
        [171280] = 7762,        -- Opal Lord Warden Axe
        [171281] = 7765,        -- Opal Nightflame Greatsword
        [171282] = 7766,        -- Opal Nightflame Bow
        [171283] = 7767,        -- Opal Nightflame Shield
        [171284] = 7768,        -- Opal Nightflame Staff
        [171285] = 7769,        -- Opal Nightflame Mace
        [171286] = 7803,        -- Opal Swarm Mother Greatsword
        [171287] = 7804,        -- Opal Swarm Mother Bow
        [171288] = 7805,        -- Opal Swarm Mother Shield
        [171289] = 7806,        -- Opal Swarm Mother Staff
        [171290] = 7807,        -- Opal Swarm Mother Mace
        [171291] = 7751,        -- Opal Iceheart Greatsword
        [171292] = 7752,        -- Opal Iceheart Bow
        [171293] = 7753,        -- Opal Iceheart Shield
        [171294] = 7754,        -- Opal Iceheart Staff
        [171295] = 7755,        -- Opal Iceheart Sword
        [171296] = 7758,        -- Opal Lord Warden Greatsword
        [171297] = 7759,        -- Opal Lord Warden Bow
        [171298] = 7760,        -- Opal Lord Warden Shield
        [171299] = 7761,        -- Opal Lord Warden Staff
        [171300] = 7762,        -- Opal Lord Warden Axe
        [171301] = 7765,        -- Opal Nightflame Greatsword
        [171302] = 7766,        -- Opal Nightflame Bow
        [171303] = 7767,        -- Opal Nightflame Shield
        [171304] = 7768,        -- Opal Nightflame Staff
        [171305] = 7769,        -- Opal Nightflame Mace
        [171306] = 7803,        -- Opal Swarm Mother Greatsword
        [171307] = 7804,        -- Opal Swarm Mother Bow
        [171308] = 7805,        -- Opal Swarm Mother Shield
        [171309] = 7806,        -- Opal Swarm Mother Staff
        [171310] = 7807,        -- Opal Swarm Mother Mace
        [171311] = 7757,        -- Opal Iceheart's Shoulder
        [171312] = 7771,        -- Opal Nightflame's Shoulder
        [171313] = 7809,        -- Opal Swarm Mother's Shoulder
        [171330] = 8221,        -- Snowball Buddy
        [171439] = 8856,        -- Hungering Void Battle Axe
        [171440] = 8857,        -- Hungering Void Maul
        [171441] = 8858,        -- Hungering Void Greatsword
        [171442] = 8859,        -- Hungering Void Axe
        [171443] = 8860,        -- Hungering Void Bow
        [171444] = 8861,        -- Hungering Void Mace
        [171445] = 8862,        -- Hungering Void Shield
        [171446] = 8863,        -- Hungering Void Staff
        [171447] = 8864,        -- Hungering Void Sword
        [171448] = 8865,        -- Hungering Void Dagger
        [171471] = 8197,        -- Dominion Breton Terrier
        [171472] = 8198,        -- Covenant Breton Terrier
        [171473] = 8196,        -- Pact Breton Terrier
        [171477] = 8125,        -- Slag Town Diver
        [171478] = 8658,        -- Thetys Ramarys's Bait Kit
        [171533] = 8655,        -- Rage of the Reach
        [171578] = 8959,        -- Symphony of Blades Shoulder
        [171579] = 8958,        -- Symphony of Blades Mask
        [171597] = 9002,        -- Stonekeeper Shoulder
        [171598] = 9001,        -- Stonekeeper Mask
        [171715] = 9020,        -- Regal Regalia Jerkin
        [171716] = 9020,        -- Regal Regalia Jerkin
        [171717] = 9021,        -- Regal Regalia Hat
        [171718] = 9021,        -- Regal Regalia Hat
        [171719] = 9022,        -- Regal Regalia Breeches
        [171720] = 9022,        -- Regal Regalia Breeches
        [171721] = 9023,        -- Regal Regalia Epaulets
        [171722] = 9023,        -- Regal Regalia Epaulets
        [171723] = 9024,        -- Regal Regalia Shoes
        [171724] = 9024,        -- Regal Regalia Shoes
        [171725] = 9025,        -- Regal Regalia Gloves
        [171726] = 9025,        -- Regal Regalia Gloves
        [171727] = 9026,        -- Regal Regalia Sash
        [171728] = 9026,        -- Regal Regalia Sash
        [171733] = 9028,        -- Imperial Champion Battle Axe
        [171734] = 9029,        -- Imperial Champion Bow
        [171735] = 9030,        -- Imperial Champion Shield
        [171736] = 9031,        -- Imperial Champion Staff
        [171737] = 9032,        -- Imperial Champion Axe
        [171738] = 9033,        -- Imperial Champion Maul
        [171739] = 9034,        -- Imperial Champion Greatsword
        [171740] = 9035,        -- Imperial Champion Mace
        [171741] = 9036,        -- Imperial Champion Sword
        [171742] = 9037,        -- Imperial Champion Dagger
        [171743] = 9028,        -- Imperial Champion Battle Axe
        [171744] = 9033,        -- Imperial Champion Maul
        [171745] = 9034,        -- Imperial Champion Greatsword
        [171746] = 9032,        -- Imperial Champion Axe
        [171747] = 9029,        -- Imperial Champion Bow
        [171748] = 9035,        -- Imperial Champion Mace
        [171749] = 9030,        -- Imperial Champion Shield
        [171750] = 9031,        -- Imperial Champion Staff
        [171751] = 9036,        -- Imperial Champion Sword
        [171752] = 9037,        -- Imperial Champion Dagger
}

function uespLog.BoolToOnOff(flag)
	if (flag) then return "on" end
	return "off"
end


function uespLog.GetMessageDisplay(msgType)

	if (uespLog.savedVars.settings == nil) then
		uespLog.savedVars.settings = uespLog.DEFAULT_SETTINGS
	end
	
	if (uespLog.savedVars.settings.data.messageDisplay == nil) then
		uespLog.savedVars.settings.data.messageDisplay = uespLog.DEFAULT_SETTINGS.messageDisplay
	end
	
	if (uespLog.savedVars.settings.data.messageDisplay[msgType] == nil) then
		return false
	end
	
	return uespLog.savedVars.settings.data.messageDisplay[msgType]
end


function uespLog.SetMessageDisplay(msgType, flag)

	if (uespLog.savedVars.settings == nil) then
		uespLog.savedVars.settings = uespLog.DEFAULT_SETTINGS
	end
	
	uespLog.savedVars.settings.data.messageDisplay[msgType] = flag
end


function uespLog.GetCustomStatDisplay()

	if (uespLog.savedVars.settings == nil) then
		uespLog.savedVars.settings = uespLog.DEFAULT_SETTINGS
	end
	
	if (uespLog.savedVars.settings.data.customStatDisplay == nil) then
		uespLog.savedVars.settings.data.customStatDisplay = uespLog.DEFAULT_SETTINGS.customStatDisplay
	end
	
	return uespLog.savedVars.settings.data.customStatDisplay
end


function uespLog.SetCustomStatDisplay(flag)

	if (uespLog.savedVars.settings == nil) then
		uespLog.savedVars.settings = uespLog.DEFAULT_SETTINGS
	end
	
	uespLog.savedVars.settings.data.customStatDisplay = flag
end


function uespLog.GetCloseMarketAnnouncement()

	if (uespLog.savedVars.settings == nil) then
		uespLog.savedVars.settings = uespLog.DEFAULT_SETTINGS
	end
	
	if (uespLog.savedVars.settings.data.closeMarketAnnouncement == nil) then
		uespLog.savedVars.settings.data.closeMarketAnnouncement = uespLog.DEFAULT_SETTINGS.closeMarketAnnouncement
	end
	
	return uespLog.savedVars.settings.data.closeMarketAnnouncement
end


function uespLog.SetCloseMarketAnnouncement(flag)

	if (uespLog.savedVars.settings == nil) then
		uespLog.savedVars.settings = uespLog.DEFAULT_SETTINGS
	end
	
	uespLog.savedVars.settings.data.closeMarketAnnouncement = flag
end


function uespLog.GetContainerAutoLoot()

	if (uespLog.savedVars.settings == nil) then
		uespLog.savedVars.settings = uespLog.DEFAULT_SETTINGS
	end
	
	if (uespLog.savedVars.settings.data.containerAutoLoot == nil) then
		uespLog.savedVars.settings.data.containerAutoLoot = uespLog.DEFAULT_SETTINGS.containerAutoLoot
	end
	
	return uespLog.savedVars.settings.data.containerAutoLoot
end


function uespLog.SetContainerAutoLoot(flag)

	if (uespLog.savedVars.settings == nil) then
		uespLog.savedVars.settings = uespLog.DEFAULT_SETTINGS
	end
	
	uespLog.savedVars.settings.data.containerAutoLoot = flag
end


function uespLog.GetTrackStat(powerType)

	if (uespLog.savedVars.settings == nil) then
		uespLog.savedVars.settings = uespLog.DEFAULT_SETTINGS
	end
	
	if (uespLog.savedVars.settings.data.trackStat == nil) then
		uespLog.savedVars.settings.data.trackStat = uespLog.DEFAULT_SETTINGS.trackStat
	end
	
	if (powerType == nil) then
		return uespLog.savedVars.settings.data.trackStat
	end
	
	local flag = uespLog.savedVars.settings.data.trackStat[powerType]
	
	if (flag == nil) then
		return false
	end
	
	return flag
end


function uespLog.SetTrackStat(powerType, flag)

	if (uespLog.savedVars.settings == nil) then
		uespLog.savedVars.settings = uespLog.DEFAULT_SETTINGS
	end
	
	if (uespLog.savedVars.settings.data.trackStat == nil) then
		uespLog.savedVars.settings.data.trackStat = uespLog.DEFAULT_SETTINGS.trackStat
	end
	
	uespLog.savedVars.settings.data.trackStat[powerType] = flag
end


function uespLog.GetTrackLoot()

	if (uespLog.savedVars.settings == nil) then
		uespLog.savedVars.settings = uespLog.DEFAULT_SETTINGS
	end
	
	if (uespLog.savedVars.settings.data.trackLoot == nil) then
		uespLog.savedVars.settings.data.trackLoot = uespLog.DEFAULT_SETTINGS.trackLoot
	end
	
	return uespLog.savedVars.settings.data.trackLoot
end


function uespLog.SetTrackLoot(flag)

	if (uespLog.savedVars.settings == nil) then
		uespLog.savedVars.settings = uespLog.DEFAULT_SETTINGS
	end
	
	if (uespLog.savedVars.settings.data.trackLoot == nil) then
		uespLog.savedVars.settings.data.trackLoot = uespLog.DEFAULT_SETTINGS.trackLoot
	end
	
	uespLog.savedVars.settings.data.trackLoot = flag
end


function uespLog.GetKeepChatOpen()

	if (uespLog.savedVars.settings == nil) then
		uespLog.savedVars.settings = uespLog.DEFAULT_SETTINGS
	end
	
	if (uespLog.savedVars.settings.data.keepChatOpen == nil) then
		uespLog.savedVars.settings.data.keepChatOpen = uespLog.DEFAULT_SETTINGS.keepChatOpen
	end
	
	return uespLog.savedVars.settings.data.keepChatOpen
end


function uespLog.SetKeepChatOpen(flag)

	if (uespLog.savedVars.settings == nil) then
		uespLog.savedVars.settings = uespLog.DEFAULT_SETTINGS
	end
	
	if (uespLog.savedVars.settings.data.keepChatOpen == nil) then
		uespLog.savedVars.settings.data.keepChatOpen = uespLog.DEFAULT_SETTINGS.keepChatOpen
	end
	
	uespLog.savedVars.settings.data.keepChatOpen = flag
end


function uespLog.GetNirnSound()

	if (uespLog.savedVars.settings == nil) then
		uespLog.savedVars.settings = uespLog.DEFAULT_SETTINGS
	end
	
	if (uespLog.savedVars.settings.data.nirnSound == nil) then
		uespLog.savedVars.settings.data.nirnSound = uespLog.DEFAULT_SETTINGS.nirnSound
	end
	
	return uespLog.savedVars.settings.data.nirnSound
end


function uespLog.SetNirnSound(flag)

	if (uespLog.savedVars.settings == nil) then
		uespLog.savedVars.settings = uespLog.DEFAULT_SETTINGS
	end
	
	if (uespLog.savedVars.settings.data.nirnSound == nil) then
		uespLog.savedVars.settings.data.nirnSound = uespLog.DEFAULT_SETTINGS.nirnSound
	end
	
	uespLog.savedVars.settings.data.nirnSound = flag
end


function uespLog.GetShowTraitIcon()

	if (uespLog.savedVars.settings == nil) then
		uespLog.savedVars.settings = uespLog.DEFAULT_SETTINGS
	end
	
	if (uespLog.savedVars.settings.data.showTraitIcon == nil) then
		uespLog.savedVars.settings.data.showTraitIcon = uespLog.DEFAULT_SETTINGS.showTraitIcon
	end
	
	return uespLog.savedVars.settings.data.showTraitIcon
end


function uespLog.SetShowTraitIcon(flag)

	if (uespLog.savedVars.settings == nil) then
		uespLog.savedVars.settings = uespLog.DEFAULT_SETTINGS
	end
	
	if (uespLog.savedVars.settings.data.showTraitIcon == nil) then
		uespLog.savedVars.settings.data.showTraitIcon = uespLog.DEFAULT_SETTINGS.showTraitIcon
	end
	
	uespLog.savedVars.settings.data.showTraitIcon = flag
end


function uespLog.GetAutoLootHirelingMails()

	if (uespLog.savedVars.settings == nil) then
		uespLog.savedVars.settings = uespLog.DEFAULT_SETTINGS
	end
	
	if (uespLog.savedVars.settings.data.autolootHirelingMails == nil) then
		uespLog.savedVars.settings.data.autolootHirelingMails = uespLog.DEFAULT_SETTINGS.autolootHirelingMails
	end
	
	return uespLog.savedVars.settings.data.autolootHirelingMails
end


function uespLog.SetAutoLootHirelingMails(flag)

	if (uespLog.savedVars.settings == nil) then
		uespLog.savedVars.settings = uespLog.DEFAULT_SETTINGS
	end
	
	uespLog.savedVars.settings.data.autolootHirelingMails = flag
end


function uespLog.GetTrackFights()

	if (uespLog.savedVars.settings == nil) then
		uespLog.savedVars.settings = uespLog.DEFAULT_SETTINGS
	end
	
	if (uespLog.savedVars.settings.data.trackFights == nil) then
		uespLog.savedVars.settings.data.trackFights = uespLog.DEFAULT_SETTINGS.trackFights
	end
	
	return uespLog.savedVars.settings.data.trackFights
end


function uespLog.SetTrackFights(flag)

	if (uespLog.savedVars.settings == nil) then
		uespLog.savedVars.settings = uespLog.DEFAULT_SETTINGS
	end
	
	if (uespLog.savedVars.settings.data.trackFights == nil) then
		uespLog.savedVars.settings.data.trackFights = uespLog.DEFAULT_SETTINGS.trackFights
	end
	
	uespLog.savedVars.settings.data.trackFights = flag
end


function uespLog.GetInventoryStatsConfig()

	if (uespLog.savedVars.settings == nil) then
		uespLog.savedVars.settings = uespLog.DEFAULT_SETTINGS
	end
	
	if (uespLog.savedVars.settings.data.inventoryStats == nil) then
		uespLog.savedVars.settings.data.inventoryStats = uespLog.DEFAULT_SETTINGS.inventoryStats
	end
	
	return uespLog.savedVars.settings.data.inventoryStats
end


function uespLog.SetInventoryStatsConfig(value)

	if (uespLog.savedVars.settings == nil) then
		uespLog.savedVars.settings = uespLog.DEFAULT_SETTINGS
	end
	
	if (uespLog.savedVars.settings.data.inventoryStats == nil) then
		uespLog.savedVars.settings.data.inventoryStats = uespLog.DEFAULT_SETTINGS.inventoryStats
	end
	
	uespLog.savedVars.settings.data.inventoryStats = value
end



function uespLog.GetFishingFlag()

	if (uespLog.savedVars.settings == nil) then
		uespLog.savedVars.settings = uespLog.DEFAULT_SETTINGS
	end
	
	if (uespLog.savedVars.settings.data.fishing == nil) then
		uespLog.savedVars.settings.data.fishing = uespLog.DEFAULT_SETTINGS.fishing
	end
	
	return uespLog.savedVars.settings.data.fishing
end


function uespLog.SetFishingFlag(flag)

	if (uespLog.savedVars.settings == nil) then
		uespLog.savedVars.settings = uespLog.DEFAULT_SETTINGS
	end
	
	uespLog.savedVars.settings.data.fishing = flag
end


function uespLog.GetLoreBookMsgFlag()

	if (uespLog.savedVars.settings == nil) then
		uespLog.savedVars.settings = uespLog.DEFAULT_SETTINGS
	end
	
	if (uespLog.savedVars.settings.data.loreBookMsg == nil) then
		uespLog.savedVars.settings.data.loreBookMsg = uespLog.DEFAULT_SETTINGS.loreBookMsg
	end
	
	return uespLog.savedVars.settings.data.loreBookMsg
end


function uespLog.SetLoreBookMsgFlag(flag)

	if (uespLog.savedVars.settings == nil) then
		uespLog.savedVars.settings = uespLog.DEFAULT_SETTINGS
	end
	
	uespLog.savedVars.settings.data.loreBookMsg = flag
end


function uespLog.GetShowCursorMapCoordsFlag()

	if (uespLog.savedVars.settings == nil) then
		uespLog.savedVars.settings = uespLog.DEFAULT_SETTINGS
	end
	
	if (uespLog.savedVars.settings.data.showCursorMapCoords == nil) then
		uespLog.savedVars.settings.data.showCursorMapCoords = uespLog.DEFAULT_SETTINGS.showCursorMapCoords
	end
	
	return uespLog.savedVars.settings.data.showCursorMapCoords 
end


function uespLog.SetShowCursorMapCoordsFlag(flag)

	if (uespLog.savedVars.settings == nil) then
		uespLog.savedVars.settings = uespLog.DEFAULT_SETTINGS
	end
	
	uespLog.savedVars.settings.data.showCursorMapCoords = flag 
end


function uespLog.GetSaveExtendedCharData()

	if (uespLog.savedVars.settings == nil) then
		uespLog.savedVars.settings = uespLog.DEFAULT_SETTINGS
	end
	
	if (uespLog.savedVars.settings.data.saveExtendedCharData == nil) then
		uespLog.savedVars.settings.data.saveExtendedCharData = uespLog.DEFAULT_SETTINGS.saveExtendedCharData
	end
	
	return uespLog.savedVars.settings.data.saveExtendedCharData
end


function uespLog.SetSaveExtendedCharData(flag)

	if (uespLog.savedVars.settings == nil) then
		uespLog.savedVars.settings = uespLog.DEFAULT_SETTINGS
	end
	
	uespLog.savedVars.settings.data.saveExtendedCharData = flag
end


function uespLog.GetAutoSaveCharData()

	if (uespLog.savedVars.settings == nil) then
		uespLog.savedVars.settings = uespLog.DEFAULT_SETTINGS
	end
	
	if (uespLog.savedVars.settings.data.autoSaveCharData == nil) then
		uespLog.savedVars.settings.data.autoSaveCharData = uespLog.DEFAULT_SETTINGS.autoSaveCharData
	end
	
	return uespLog.savedVars.settings.data.autoSaveCharData
end


function uespLog.SetAutoSaveCharData(flag)

	if (uespLog.savedVars.settings == nil) then
		uespLog.savedVars.settings = uespLog.DEFAULT_SETTINGS
	end
	
	uespLog.savedVars.settings.data.autoSaveCharData = flag
end


function uespLog.GetAutoSaveZoneCharData()

	if (uespLog.savedVars.settings == nil) then
		uespLog.savedVars.settings = uespLog.DEFAULT_SETTINGS
	end
	
	if (uespLog.savedVars.settings.data.autoSaveZoneCharData == nil) then
		uespLog.savedVars.settings.data.autoSaveZoneCharData = uespLog.DEFAULT_SETTINGS.autoSaveZoneCharData
	end
	
	return uespLog.savedVars.settings.data.autoSaveZoneCharData
end


function uespLog.SetAutoSaveZoneCharData(flag)

	if (uespLog.savedVars.settings == nil) then
		uespLog.savedVars.settings = uespLog.DEFAULT_SETTINGS
	end
	
	uespLog.savedVars.settings.data.autoSaveZoneCharData = flag
end


function uespLog.GetCharDataPassword()

	if (uespLog.savedVars.settings == nil) then
		uespLog.savedVars.settings = uespLog.DEFAULT_SETTINGS
	end
	
	if (uespLog.savedVars.settings.data.charDataPassword == nil) then
		uespLog.savedVars.settings.data.charDataPassword = uespLog.DEFAULT_SETTINGS.charDataPassword
	end
	
	return uespLog.savedVars.settings.data.charDataPassword
end


function uespLog.GetCharDataOldPassword()

	if (uespLog.savedVars.settings == nil) then
		uespLog.savedVars.settings = uespLog.DEFAULT_SETTINGS
	end
	
	if (uespLog.savedVars.settings.data.charDataOldPassword == nil) then
		uespLog.savedVars.settings.data.charDataOldPassword = uespLog.DEFAULT_SETTINGS.charDataOldPassword
	end
	
	return uespLog.savedVars.settings.data.charDataOldPassword
end


function uespLog.SetCharDataPassword(passwd)

	if (uespLog.savedVars.settings == nil) then
		uespLog.savedVars.settings = uespLog.DEFAULT_SETTINGS
	end
	
	uespLog.savedVars.settings.data.charDataPassword = passwd
end


function uespLog.GetTreasureTimers()

	if (uespLog.savedVars.settings == nil) then
		uespLog.savedVars.settings = uespLog.DEFAULT_SETTINGS
	end
	
	if (uespLog.savedVars.settings.data.TREASURE_TIMER_DURATIONS == nil) then
		uespLog.savedVars.settings.data.TREASURE_TIMER_DURATIONS = uespLog.DEFAULT_SETTINGS.TREASURE_TIMER_DURATIONS
	end
	
	return uespLog.savedVars.settings.data.TREASURE_TIMER_DURATIONS
end


function uespLog.IsTreasureTimerEnabled()

	if (uespLog.savedVars.settings == nil) then
		uespLog.savedVars.settings = uespLog.DEFAULT_SETTINGS
	end
	
	if (uespLog.savedVars.settings.data.enabledTreasureTimers == nil) then
		uespLog.savedVars.settings.data.enabledTreasureTimers = uespLog.DEFAULT_SETTINGS.enabledTreasureTimers
	end
	
	return uespLog.savedVars.settings.data.enabledTreasureTimers
end


function uespLog.SetTreasureTimerEnabled(flag)

	if (uespLog.savedVars.settings == nil) then
		uespLog.savedVars.settings = uespLog.DEFAULT_SETTINGS
	end
	
	uespLog.savedVars.settings.data.enabledTreasureTimers = flag
end	


function uespLog.GetTotalInspiration()

	if (uespLog.savedVars.settings == nil) then
		uespLog.savedVars.settings = uespLog.DEFAULT_SETTINGS
	end
	
	if (uespLog.savedVars.settings.data.totalInspiration == nil) then
		uespLog.savedVars.settings.data.totalInspiration = 0
	end
	
	return uespLog.savedVars.settings.data.totalInspiration
end


function uespLog.SetTotalInspiration(value)

	if (uespLog.savedVars.settings == nil) then
		uespLog.savedVars.settings = uespLog.DEFAULT_SETTINGS
	end
	
	uespLog.savedVars.settings.data.totalInspiration = value
end


function uespLog.AddTotalInspiration(value)

	if (uespLog.savedVars.settings == nil) then
		uespLog.savedVars.settings = uespLog.DEFAULT_SETTINGS
	end
	
	if (uespLog.savedVars.settings.data.totalInspiration == nil) then
		uespLog.savedVars.settings.data.totalInspiration = 0
	end
	
	uespLog.savedVars.settings.data.totalInspiration = uespLog.savedVars.settings.data.totalInspiration + value
end


function uespLog.IsMailDeleteNotify()

	if (uespLog.savedVars.settings == nil) then
		uespLog.savedVars.settings = uespLog.DEFAULT_SETTINGS
	end
	
	return uespLog.savedVars.settings.data.mailDeleteNotify
end


function uespLog.SetMailDeleteNotify(flag)

	if (uespLog.savedVars.settings == nil) then
		uespLog.savedVars.settings = uespLog.DEFAULT_SETTINGS
	end
	
	uespLog.savedVars.settings.data.mailDeleteNotify = flag
end	


function uespLog.NotifyDeleteMailAdded (self)

	if not self.mailId or not self:IsMailDeletable() then
		return
	end

	local numAttachments, attachedMoney = GetMailAttachmentInfo(self.mailId)
	self.pendingDelete = true

	if numAttachments > 0 and attachedMoney > 0 then
		ZO_Dialogs_ShowDialog("DELETE_MAIL_ATTACHMENTS_AND_MONEY", self.mailId)
	elseif numAttachments > 0 then
		ZO_Dialogs_ShowDialog("DELETE_MAIL_ATTACHMENTS", self.mailId)
	elseif attachedMoney > 0 then
		ZO_Dialogs_ShowDialog("DELETE_MAIL_MONEY", self.mailId)
	elseif uespLog.IsMailDeleteNotify() then
		ZO_Dialogs_ShowDialog("DELETE_MAIL", { callback = function(...) self:ConfirmDelete(...) end, mailId = self.mailId } )
	else
		self.confirmedDelete = false
		self:ConfirmDelete(self.mailId)
	end
		
end


function uespLog.IsDebug()

	if (uespLog.savedVars.settings == nil) then
		uespLog.savedVars.settings = uespLog.DEFAULT_SETTINGS
	end
	
	if (uespLog.savedVars.settings.data.debug == nil) then
		uespLog.savedVars.settings.data.debug = uespLog.DEFAULT_SETTINGS.data.debug
	end
	
	return uespLog.savedVars.settings.data.debug
end


function uespLog.IsDebugExtra()

	if (uespLog.savedVars.settings == nil) then
		uespLog.savedVars.settings = uespLog.DEFAULT_SETTINGS
	end
	
	if (uespLog.savedVars.settings.data.debugExtra == nil) then
		uespLog.savedVars.settings.data.debugExtra = uespLog.DEFAULT_SETTINGS.data.debugExtra
	end
	
	return uespLog.savedVars.settings.data.debugExtra
end


function uespLog.IsColor()

	if (uespLog.savedVars.settings == nil) then
		uespLog.savedVars.settings = uespLog.DEFAULT_SETTINGS
	end
	
	return uespLog.savedVars.settings.data.color
end


function uespLog.IsPvpUpdate()

	if (uespLog.savedVars.settings == nil) then
		uespLog.savedVars.settings = uespLog.DEFAULT_SETTINGS
	end
	
	return uespLog.savedVars.settings.data.pvpUpdate
end


function uespLog.SetDebug(flag)
	if (uespLog.savedVars.settings == nil) then
		uespLog.savedVars.settings = uespLog.DEFAULT_SETTINGS
	end
	
	uespLog.savedVars.settings.data.debug = flag
end	


function uespLog.SetPvpUpdate(flag)
	if (uespLog.savedVars.settings == nil) then
		uespLog.savedVars.settings = uespLog.DEFAULT_SETTINGS
	end
	
	uespLog.savedVars.settings.data.pvpUpdate = flag
end	


function uespLog.SetColor(flag)
	if (uespLog.savedVars.settings == nil) then
		uespLog.savedVars.settings = uespLog.DEFAULT_SETTINGS
	end
	
	uespLog.savedVars.settings.data.color = flag
end	


function uespLog.SetDebugExtra(flag)

	if (uespLog.savedVars.settings == nil) then
		uespLog.savedVars.settings = uespLog.DEFAULT_SETTINGS
	end
	
	uespLog.savedVars.settings.data.debugExtra = flag
end	


function uespLog.IsLogData()

	if (uespLog.savedVars.settings == nil) then
		uespLog.savedVars.settings = uespLog.DEFAULT_SETTINGS
	end
	
	return uespLog.savedVars.settings.data.logData
end


function uespLog.SetLogData(flag)
	if (uespLog.savedVars.settings == nil) then
		uespLog.savedVars.settings = uespLog.DEFAULT_SETTINGS
	end
	
	uespLog.savedVars.settings.data.logData = flag
end	


function uespLog.Msg(text)
    d(text)
end


function uespLog.MsgType(msgType, text)

	if (uespLog.GetMessageDisplay(msgType)) then
		d(text)
	end
	
end


function uespLog.MsgColorType(msgType, Color, text)

	if (uespLog.GetMessageDisplay(msgType)) then
	
		if (uespLog.IsColor()) then
			d("|c" .. Color .. text .. "|r")
		else
			d(text)
		end
	end
	
end


function uespLog.MsgColor(Color, text)

	if (uespLog.IsColor()) then
		d("|c" .. Color .. text .. "|r")
	else
		d(text)
	end
	
end


function uespLog.DebugLogMsg(text)

	if (uespLog.IsDebug()) then
	
		if (not uespLog.IsLogData()) then 
			text = "UESP: Ignored " .. text
		else
			text = "UESP: " .. text
		end
		
		d(text)
	end

end


function uespLog.DebugLogMsgColor(Color, text)

	if (uespLog.IsDebug()) then
	
		if (not uespLog.IsLogData()) then 
			text = "UESP: Ignored " .. text
		else
			text = "UESP: " .. text
		end
		
		if (uespLog.IsColor()) then
			d("|c" .. Color .. text.."|r")
		else
			d(text)
		end
	end

end


function uespLog.DebugMsg(text)
	if (uespLog.IsDebug()) then
	
		if (not uespLog.IsLogData()) then 
			text = text .. " (logging off)"
		end
		
		d(text)
	end
end


function uespLog.DebugMsgColor(Color, text)

	if (uespLog.IsDebug()) then
	
		if (not uespLog.IsLogData()) then 
			text = text .. " (logging off)"
		end
		
		if (uespLog.IsColor()) then
			d("|c" .. Color .. text .. "|r")
		else
			d(text)
		end
	end
	
end


function uespLog.DebugExtraMsg(text)

	if (uespLog.IsDebugExtra()) then
	
		if (uespLog.IsColor()) then
			d("|c" .. uespLog.debugColor .. text .. "|r")
		else
			d(text)
		end
	end
	
end


function uespLog.gameTime()
	return GetGameTimeMilliseconds()
end


function uespLog.EndsWith(s, send)
	return #s >= #send and s:find(send, #s-#send+1, true) and true or false
end


function uespLog.BeginsWith(s, sBegin)
	return string.sub(s, 1, string.len(sBegin)) == sBegin
end


function uespLog.AppendDataToLog(section, ...)

	if (not uespLog.IsLogData()) then return end
	
	local logString = ""
	local arg = {...}
		
	for i = 1, #arg do
		local argValue = arg[i]
		
		if (argValue == nil) then
			-- Skip nil inputs
		elseif (type(argValue) == "table") then
			
					-- Try to make the event the first thing output
			if (argValue.event ~= nil) then
				logString = logString .. "event{" .. tostring(argValue.event) .. "}  "
			end
			
			for varName, varValue in pairs(argValue) do
				if (varName ~= "event") then
					logString = logString .. tostring(varName).."{" .. tostring(varValue) .. "}  "
				end
			end
		else
			logString = logString .. "unknown{" .. tostring(argValue) .. "}  "
		end
    end
	
	logString = logString .. "lang{".. GetCVar("Language.2") .."}  "
	
	uespLog.AppendStringToLog(section, logString)
end


function uespLog.AppendStringToLog(section, logString)

	if (not uespLog.IsLogData()) then return end
	if (logString == nil) then return end

	if (uespLog.savedVars[section] == nil) then
		uespLog.DebugMsg("UESP: Error -- The section" .. tostring(section) .." is not valid!")
		return
	end
	
	local sv = uespLog.savedVars[section].data
	
	if (sv == nil) then
		uespLog.savedVars[section].data = { }
		sv = uespLog.savedVars[section].data
	end
		
		
	if (uespLog.EnableSectionSizeWarning) then
	
		if (uespLog.NextSectionSizeWarning[section] == nil) then
			uespLog.NextSectionSizeWarning[section] = uespLog.FIRST_SECTION_SIZE_WARNING
			uespLog.NextSectionWarningGameTime[section] = 0
		end
			
		if (#sv >= uespLog.NextSectionSizeWarning[section] and GetGameTimeMilliseconds() >= uespLog.NextSectionWarningGameTime[section]) then
			uespLog.MsgColor(uespLog.SECTION_SIZE_WARNING_COLOR, "WARNING: Log '"..tostring(section).."' data exceeds "..tostring(#sv).." elements in size.")
			uespLog.MsgColor(uespLog.SECTION_SIZE_WARNING_COLOR, "Loss of data is possible when loading the saved variable file!")
			uespLog.MsgColor(uespLog.SECTION_SIZE_WARNING_COLOR, "You should save the data, submit it to the UESP and do \"/uespreset all\".")
			uespLog.NextSectionSizeWarning[section] = #sv + uespLog.NEXT_SECTION_SIZE_WARNING
			uespLog.NextSectionWarningGameTime[section] = GetGameTimeMilliseconds() + uespLog.NEXT_SECTION_SIZE_WARNING_TIMEMS
		end
	end
	
		-- Fix long strings being output as "nil"
	while (#logString >= uespLog.MAX_LOGSTRING_LENGTH) do
		local firstPart = string.sub(logString, 1, uespLog.MAX_LOGSTRING_LENGTH)
		local secondPart = string.sub(logString, uespLog.MAX_LOGSTRING_LENGTH+1, -1)
		sv[#sv+1] = firstPart .. "#STR#"
		logString = "#STR#" .. secondPart
	end
	
	sv[#sv+1] = logString
end


function uespLog.GetTimeData()
	local result = { }
	local timestamp = GetTimeStamp()
	
	result.timeStamp = Id64ToString(timestamp)
	result.timeStamp1 = tostring(timestamp)
	result.gameTime = GetGameTimeMilliseconds()
	
	return result
end


function uespLog.GetLastTargetData()
	local result = { }
	
	result.x = uespLog.lastTargetData.x
	result.y = uespLog.lastTargetData.y
	result.zone = uespLog.lastTargetData.zone
	result.lastTarget = uespLog.lastTargetData.name
	
	result.worldx = uespLog.lastTargetData.worldx
	result.worldy = uespLog.lastTargetData.worldy
	result.worldz = uespLog.lastTargetData.worldz
	result.worldzoneid = uespLog.lastTargetData.worldzoneid
	
	return result
end


function uespLog.GetCurrentTargetData()
	local result = { }
	
	result.x = uespLog.currentTargetData.x
	result.y = uespLog.currentTargetData.y
	result.zone = uespLog.currentTargetData.zone
	result.lastTarget = uespLog.currentTargetData.name
	
	result.worldx = uespLog.currentTargetData.worldx
	result.worldy = uespLog.currentTargetData.worldy
	result.worldz = uespLog.currentTargetData.worldz
	result.worldzoneid = uespLog.currentTargetData.worldzoneid
	
	return result
end


function uespLog.GetPlayerPositionData()
	return uespLog.GetUnitPositionData("player")
end


function uespLog.GetUnitPositionData(unitTag)
	local result = { }
	local useTag = unitTag
	
	if (unitTag == "reticleover") then
		useTag = "player"
	elseif (unitTag == "interact") then
		useTag = "player"
	end

	result.x, result.y = GetMapPlayerPosition(useTag)	
	result.zone = GetMapName()
	
	if (GetUnitRawWorldPosition ~= nil) then
		result.worldzoneid, result.worldx, result.worldy, result.worldz = GetUnitRawWorldPosition("player")
	end
	
	return result
end


function uespLog.GetUnitPosition(unitName)
	local x, y, z
	local worldzoneid = nil
	local worldx = nil
	local worldy = nil
	local worldz = nil
	local useTag = unitName
                     
	if (unitName == "reticleover") then
		useTag = "player"
		x, y, z = GetMapPlayerPosition("player")
	elseif (unitName == "interact") then
		useTag = "player"
		x, y, z = GetMapPlayerPosition("player")
	else
		x, y, z = GetMapPlayerPosition(unitName)
	end
	
	local zone = GetMapName()
	
	if (GetUnitRawWorldPosition ~= nil) then
		worldzoneid, worldx, worldy, worldz = GetUnitRawWorldPosition("player")
	end
	
	return x, y, z, zone, worldzoneid, worldx, worldy, worldz
end


function uespLog.GetPlayerPosition()
	return uespLog.GetUnitPosition("player")
end


function uespLog.ParseLink(link)
	local text, color, itemId, data2, allData, niceName, niceLink = uespLog.ParseLinkID(link)
	
	return text, color, allData, niceName, niceLink
end


function uespLog.ParseLinkItemId(link)

	if (link == nil or link == "") then
		return -1, -1, -1
	end
	
	local linkType, itemText, itemId, internalSubType, internalLevel = link:match("|H(.-):(.-):(.-):(.-):(.-):")	
	
	if (itemId == nil or internalSubType == nil or internalLevel == nil) then
		return -1, -1, -1
	end

	return tonumber(itemId),tonumber(internalSubType), tonumber(internalLevel)
end


function uespLog.ParseItemLinkEx(link)
	--|H1:item:Id:SubType:InternalLevel:EnchantId:EnchantSubType:EnchantLevel:Writ1:Writ2:Writ3:Writ4:Writ5:Writ6:0:0:0:Style:Crafted:Bound:Stolen::Charges:PotionEffect/WritReward|hName|h
	local linkData = {}
	
	if (link == nil) then
		return false
	end
	
	linkData.linkType, linkData.itemText, linkData.itemId, linkData.internalSubType, linkData.internalLevel, linkData.enchantId, linkData.enchantSubtype, linkData.enchantLevel, linkData.writ1, linkData.writ2, linkData.writ3, linkData.writ4, linkData.writ5, linkData.writ6, linkData.zero1, linkData.zero2, linkData.zero3, linkData.style, linkData.crafted, linkData.bound, linkData.stolen, linkData.charges, linkData.potionData, linkData.itemName = link:match("|H(.-):(.-):(.-):(.-):(.-):(.-):(.-):(.-):(.-):(.-):(.-):(.-):(.-):(.-):(.-):(.-):(.-):(.-):(.-):(.-):(.-):(.-):(.-)|h(.-)|h")	
	
	if (linkData.linkType == nil) then
		return false
	end
	
	linkData.itemId = tonumber(linkData.itemId)
	linkData.internalSubType = tonumber(linkData.internalSubType)
	linkData.internalLevel = tonumber(linkData.internalLevel)
	linkData.enchantId = tonumber(linkData.enchantId)
	linkData.enchantSubtype = tonumber(linkData.enchantSubtype)
	linkData.enchantLevel = tonumber(linkData.enchantLevel)
	linkData.writ1 = tonumber(linkData.writ1)
	linkData.writ2 = tonumber(linkData.writ2)
	linkData.writ3 = tonumber(linkData.writ3)
	linkData.writ4 = tonumber(linkData.writ4)
	linkData.writ5 = tonumber(linkData.writ5)
	linkData.writ6 = tonumber(linkData.writ6)
	linkData.zero1 = tonumber(linkData.zero1)
	linkData.zero2 = tonumber(linkData.zero2)
	linkData.zero3 = tonumber(linkData.zero3)
	linkData.style = tonumber(linkData.style)
	linkData.crafted = tonumber(linkData.crafted)
	linkData.bound = tonumber(linkData.bound)
	linkData.stolen = tonumber(linkData.stolen)
	linkData.charges = tonumber(linkData.charges)
	linkData.potionData = tonumber(linkData.potionData)
	
	return linkData
end


function uespLog.ParseLinkID(link)
	--|HFFFFFF:item:45817:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|hJode|h
	
	if (type(link) == "string") then
		local color, itemType, itemId, internalSubType, internalLevel, data, text = link:match("|H(.-):(.-):(.-):(.-):(.-):(.-)|h(.-)|h")
		
		if (color == nil or itemId == nil or internalSubType == nil or data == nil) then
			return link, "", "", "", "", link, link
		end
		
		local niceName = link
		local niceLink = link
		local allData = itemId..":"..internalSubType .. ":" .. internalLevel .. ":" .. data
		
		if (text == "") then
			text = GetItemLinkName(link)
			local i = text:find("|")
			
				-- Remove text after | in some item names in update 10
			if (i ~= nil) then
				text = text:sub(1, i-1)
			end
			
				-- Remove item names with brackets
			local firstChar = text:sub(1, 1)
			
			if (firstChar == "[") then
				text = text:sub(2)
			end
			
			local lastChar = text:sub(-1, -1)
			
			if (lastChar == "]") then
				text = text:sub(1, -2)
			end

		end
		
		if (text ~= nil) then
			niceName = text:gsub("%^.*", "")
			--niceLink = "|H"..color..":"..itemType..":"..allData.."|h["..niceName.."]|h"
			niceLink = "|H1:"..itemType..":"..allData.."|h|h"
		end		
		
		return text, color, itemId, internalLevel, allData, niceName, niceLink, internalSubType
    end
	
	return "", "", "", "", "", "", link, ""
end



function uespLog.MakeNiceLink(link)
	
	if type(link) == "string" then
		local color, data, text = link:match("|H(.-):(.-)|h(.-)|h")
		
		if (color == nil or text == nil or data == nil) then
			return link, ""
		end
		
		local niceName = link
		local niceLink = link
		
		if (text == "") then
			text = GetItemLinkName(link)
		end
		
		if (text ~= nil) then
			niceName = text:gsub("%^.*", "")
			niceLink = "|H"..color..":"..data.."|h["..niceName.."]|h"
		end
		
		return niceLink, niceName
    end
	
	return link, ""
end


function uespLog.GetItemLinkID(link)
	--|HFFFFFF:item:45817:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|hJode|h
	
	if type(link) == "string" then
		local color, itemType, itemId, data, text = link:match("|H(.-):(.-):(.-):(.-)|h(.-)|h")
		
		if (color == nil or itemId == nil or itemType == nil or data == nil or text == nil) then
			return nil
		end
		
		local parsedId = tonumber(itemId)
		
		if (parsedId == nil or parsedId <= 0) then
			return nil
		end
		
		return parsedId
    end
	
	return nil
end


uespLog.addonMemory = {}
uespLog.initialMemory = collectgarbage('count')
uespLog.addonMemoryIndex = 1


function uespLog.ShowAddonMemory()
	local lastMemory = uespLog.initialMemory
	
	table.sort(uespLog.addonMemory, function(a, b) return a.memory < b.memory end )
	--table.sort(uespLog.addonMemory, function(a, b) return a.index < b.index end )
	
	for i, data in ipairs(uespLog.addonMemory) do
		local memory = data.memory - lastMemory
		uespLog.Msg(".    "..data.name.." (" .. data.index .. ") = "..memory)
		lastMemory = data.memory
	end

end


--	Function fired at addon loaded to setup variables and default settings
function uespLog.Initialize( self, addOnName )

	uespLog.addonMemory[#uespLog.addonMemory + 1] = { ["name"] = addOnName, ["memory"] = collectgarbage('count'), ["index"] = uespLog.addonMemoryIndex }
	uespLog.addonMemoryIndex = uespLog.addonMemoryIndex + 1

	if ( addOnName ~= "uespLog" ) then 
		return 
	end
	
		-- Causes crash when purchasing skills
	--uespLog.Old_SceneManager_Show = SCENE_MANAGER.Show
	--SCENE_MANAGER.Show = uespLog.SceneManager_Show
			
	uespLog.lastPlayerHP = GetUnitPower("player", POWERTYPE_HEALTH)
	uespLog.lastPlayerMG = GetUnitPower("player", POWERTYPE_MAGICKA)
	uespLog.lastPlayerST = GetUnitPower("player", POWERTYPE_STAMINA)
	uespLog.lastPlayerUT = GetUnitPower("player", POWERTYPE_ULTIMATE)
	
	uespLog.lastPlayerSpellDamage = GetPlayerStat(STAT_SPELL_POWER, STAT_BONUS_OPTION_APPLY_BONUS, STAT_SOFT_CAP_OPTION_APPLY_SOFT_CAP)
	uespLog.lastPlayerWeaponDamage = GetPlayerStat(STAT_POWER, STAT_BONUS_OPTION_APPLY_BONUS, STAT_SOFT_CAP_OPTION_APPLY_SOFT_CAP)
	
	uespLog.savedVars = {
		["all"] = ZO_SavedVars:NewAccountWide("uespLogSavedVars", uespLog.DATA_VERSION, "all", uespLog.DEFAULT_DATA),
		["achievements"] = ZO_SavedVars:NewAccountWide("uespLogSavedVars", uespLog.DATA_VERSION, "achievements", uespLog.DEFAULT_DATA),
		["globals"] = ZO_SavedVars:NewAccountWide("uespLogSavedVars", uespLog.DATA_VERSION, "globals", uespLog.DEFAULT_DATA),
		["info"] = ZO_SavedVars:NewAccountWide("uespLogSavedVars", uespLog.DATA_VERSION, "info", uespLog.DEFAULT_DATA),
		["houseStorage"] = ZO_SavedVars:NewAccountWide("uespLogSavedVars", uespLog.DATA_VERSION, "houseStorage", uespLog.DEFAULT_DATA),
		["settings"] = ZO_SavedVars:NewAccountWide("uespLogSavedVars", uespLog.DATA_VERSION, "settings", uespLog.DEFAULT_SETTINGS),
		["buildData"] = ZO_SavedVars:NewAccountWide("uespLogSavedVars", uespLog.DATA_VERSION, "buildData", uespLog.DEFAULT_BUILDDATA),
		["bankData"] = ZO_SavedVars:NewAccountWide("uespLogSavedVars", uespLog.DATA_VERSION, "bankData", uespLog.DEFAULT_BANKDATA),
		["craftBagData"] = ZO_SavedVars:NewAccountWide("uespLogSavedVars", uespLog.DATA_VERSION, "craftBagData", uespLog.DEFAULT_CRAFTBAGDATA),
		["tempData"] = ZO_SavedVars:NewAccountWide("uespLogSavedVars", uespLog.DATA_VERSION, "tempData", uespLog.DEFAULT_DATA),
		["skillCoef"] = ZO_SavedVars:NewAccountWide("uespLogSavedVars", uespLog.DATA_VERSION, "skillCoef", uespLog.DEFAULT_SKILLCOEF_DATA),
		["charData"] = ZO_SavedVars:New("uespLogSavedVars", uespLog.DATA_VERSION, "charData", uespLog.DEFAULT_CHARDATA),
		["charInfo"] = ZO_SavedVars:New("uespLogSavedVars", uespLog.DATA_VERSION, "charInfo", uespLog.DEFAULT_CHARINFO),
		["skillCoefAbilityList"] = ZO_SavedVars:NewAccountWide("uespLogSavedVars", uespLog.DATA_VERSION, "skillCoefAbilityList", {}),
	}
	
		-- This section is no longer being used
	uespLog.savedVars.achievements = nil
	
	if (uespLog.savedVars.settings.data.messageDisplay == nil) then
		uespLog.savedVars.settings.data.messageDisplay = uespLog.DEFAULT_SETTINGS.data.messageDisplay
		
		if (uespLog.IsDebug()) then
			uespLog.savedVars.settings.data.messageDisplay.npc = true
			uespLog.savedVars.settings.data.messageDisplay.xp = true
			uespLog.savedVars.settings.data.messageDisplay.loot = true
			uespLog.savedVars.settings.data.messageDisplay.quest = true
			uespLog.savedVars.settings.data.messageDisplay.inspiration = true
			uespLog.savedVars.settings.data.messageDisplay.other = true
		end
	end
	
	if (uespLog.savedVars.charInfo.data.fightData == nil) then
		uespLog.savedVars.charInfo.data.fightData = {}
	end
	
	uespLog.FightKillData = uespLog.savedVars.charInfo.data.fightData
	
	uespLog.InitializeTrackLootData(false)
	
	if (uespLog.savedVars.settings.data.messageDisplay.inspiration == nil) then
		uespLog.savedVars.settings.data.messageDisplay.inspiration = true
	end
	
	if (uespLog.savedVars.settings.data.targetResistance == nil) then
		uespLog.savedVars.settings.data.targetResistance = uespLog.DEFAULT_SETTINGS.data.targetResistance
	end
	
	if (uespLog.savedVars.settings.data.targetCritResistFactor == nil) then
		uespLog.savedVars.settings.data.targetCritResistFactor = uespLog.DEFAULT_SETTINGS.data.targetCritResistFactor
	end
	
	if (uespLog.savedVars.settings.data.targetCritResistFlat == nil) then
		uespLog.savedVars.settings.data.targetCritResistFlat = uespLog.DEFAULT_SETTINGS.data.targetCritResistFlat
	end
		
	if (uespLog.savedVars.charInfo.data.lastFoodEaten ~= nil) then
		uespLog.charDataLastFoodEaten = uespLog.savedVars.charInfo.data.lastFoodEaten 
	end
		
	if (uespLog.savedVars.charInfo.data.actionBar ~= nil) then
		uespLog.charData_ActionBarData = uespLog.savedVars.charInfo.data.actionBar 
		
		if (uespLog.charData_ActionBarData[3] == nil) then
			uespLog.charData_ActionBarData[3] = {}
		end
		
		if (uespLog.charData_ActionBarData[4] == nil) then
			uespLog.charData_ActionBarData[4] = {}
		end
	end
	
	if (uespLog.savedVars.charInfo.data.stats ~= nil) then
		uespLog.charData_StatsData = uespLog.savedVars.charInfo.data.stats 
		
		if (uespLog.charData_StatsData[4] == nil) then
			uespLog.charData_StatsData[4] = {}
		end
	end
	
	if (uespLog.savedVars.charInfo.data.skills ~= nil) then
		uespLog.savedVars.charInfo.data.skills = nil
	end
	
	if (uespLog.savedVars.charInfo.data.hirelingMailTime == nil) then
		uespLog.savedVars.charInfo.data.hirelingMailTime = {}
		uespLog.savedVars.charInfo.data.hirelingMailTime[CRAFTING_TYPE_PROVISIONING] = 0
		uespLog.savedVars.charInfo.data.hirelingMailTime[CRAFTING_TYPE_WOODWORKING] = 0
		uespLog.savedVars.charInfo.data.hirelingMailTime[CRAFTING_TYPE_BLACKSMITHING] = 0
		uespLog.savedVars.charInfo.data.hirelingMailTime[CRAFTING_TYPE_ENCHANTING] = 0
		uespLog.savedVars.charInfo.data.hirelingMailTime[CRAFTING_TYPE_CLOTHIER] = 0
	end	
	
	if (uespLog.savedVars.settings.data.charDataPassword == nil) then
		uespLog.savedVars.settings.data.charDataPassword = ""
	end
	
	uespLog.SkillCoefData = uespLog.savedVars.skillCoef.data.coefData
	uespLog.SkillCoefAbilityData = uespLog.savedVars.skillCoef.data.abilityData
	uespLog.UpdateSkillCoefCounts()
		
	uespLog.savedVars.settings.data.charDataOldPassword = uespLog.savedVars.settings.data.charDataPassword
	
	uespLog.mineItemsAutoNextItemId = uespLog.savedVars.settings.data.mineItemsAutoNextItemId or uespLog.mineItemsAutoNextItemId
	uespLog.mineItemsAutoLastItemId = uespLog.savedVars.settings.data.mineItemsAutoLastItemId or uespLog.mineItemsAutoLastItemId
	uespLog.mineItemsAutoNextListIndex = uespLog.savedVars.settings.data.mineItemsAutoNextListIndex or uespLog.mineItemsAutoNextListIndex
	uespLog.mineItemAutoReload = uespLog.savedVars.settings.data.mineItemAutoReload or uespLog.mineItemAutoReload
	uespLog.mineItemAutoRestart = uespLog.savedVars.settings.data.mineItemAutoRestart or uespLog.mineItemAutoRestart
	uespLog.mineItemsEnabled = uespLog.savedVars.settings.data.mineItemsEnabled or uespLog.mineItemsEnabled
	uespLog.isAutoMiningItems = uespLog.savedVars.settings.data.isAutoMiningItems or uespLog.isAutoMiningItems
	uespLog.mineItemOnlySubType = uespLog.savedVars.settings.data.mineItemOnlySubType or uespLog.mineItemOnlySubType
	uespLog.mineItemOnlyItemType = uespLog.savedVars.settings.data.mineItemOnlyItemType or uespLog.mineItemOnlyItemType
	uespLog.mineItemOnlyLevel = uespLog.savedVars.settings.data.mineItemOnlyLevel or uespLog.mineItemOnlyLevel
	uespLog.mineItemPotionData = uespLog.savedVars.settings.data.mineItemPotionData or uespLog.mineItemPotionData
	uespLog.mineItemReloadDelay = uespLog.savedVars.settings.data.mineItemReloadDelay or uespLog.mineItemReloadDelay
	uespLog.pvpUpdate = uespLog.savedVars.settings.data.pvpUpdate or uespLog.pvpUpdate
	uespLog.mineItemLastReloadTimeMS = GetGameTimeMilliseconds()
	
	if (uespLog.savedVars.settings.data.TREASURE_TIMER_DURATIONS["thieves trove"] == nil) then
		uespLog.savedVars.settings.data.TREASURE_TIMER_DURATIONS["thieves trove"] = uespLog.DEFAULT_SETTINGS.data.TREASURE_TIMER_DURATIONS["thieves trove"]
	end
	
	if (uespLog.savedVars.settings.data.salesData.savedPrices == nil) then
		uespLog.savedVars.settings.data.salesData.savedPrices = {}
	end
	
	if (uespLog.savedVars.charInfo.data.mercStyle ~= nil) then
		uespLog.savedVars.charInfo.data.mercStyle = nil
	end
	
	if (uespLog.savedVars.charInfo.data.ancientOrcStyle ~= nil) then
		uespLog.savedVars.charInfo.data.ancientOrcStyle = {}
	end	
	
	zo_callLater(uespLog.InitAutoMining, 5000)
	
	uespLog.InitSettingsMenu()
	
	EVENT_MANAGER:RegisterForEvent( "uespLog", EVENT_PLAYER_ACTIVATED, uespLog.OnPlayerActivated)
	EVENT_MANAGER:RegisterForEvent( "uespLog-initmsg", EVENT_PLAYER_ACTIVATED, uespLog.outputInitMessage)
	EVENT_MANAGER:RegisterForEvent( "uespLog-sales", EVENT_PLAYER_ACTIVATED, uespLog.OnActivateSalesData)
			
	EVENT_MANAGER:RegisterForEvent( "uespLog" , EVENT_RETICLE_TARGET_CHANGED, uespLog.OnTargetChange)
	
	EVENT_MANAGER:RegisterForEvent( "uespLog" , EVENT_PLAYER_DEACTIVATED, uespLog.OnPlayerDeactivated)
	EVENT_MANAGER:RegisterForEvent( "uespLog" , EVENT_LOGOUT_DISALLOWED, uespLog.OnLogoutDisallowed)	 
	EVENT_MANAGER:RegisterForEvent( "uespLog" , EVENT_ZONE_CHANGED, uespLog.OnZoneChanged)	
	EVENT_MANAGER:RegisterForEvent( "uespLog" , EVENT_ZONE_UPDATE, uespLog.OnZoneUpdate)	
		
	EVENT_MANAGER:RegisterForEvent( "uespLog" , EVENT_QUEST_CONDITION_COUNTER_CHANGED, uespLog.OnQuestCounterChanged)
	EVENT_MANAGER:RegisterForEvent( "uespLog" , EVENT_QUEST_ADDED, uespLog.OnQuestAdded)
	EVENT_MANAGER:RegisterForEvent( "uespLog" , EVENT_QUEST_REMOVED, uespLog.OnQuestRemoved)
	EVENT_MANAGER:RegisterForEvent( "uespLog" , EVENT_OBJECTIVE_COMPLETED, uespLog.OnQuestObjectiveCompleted)
	EVENT_MANAGER:RegisterForEvent( "uespLog" , EVENT_QUEST_COMPLETE, uespLog.OnQuestComplete)
	 	
	EVENT_MANAGER:RegisterForEvent( "uespLog" , EVENT_QUEST_ADVANCED, uespLog.OnQuestAdvanced)	
	EVENT_MANAGER:RegisterForEvent( "uespLog" , EVENT_QUEST_COMPLETE_EXPERIENCE, uespLog.OnQuestCompleteExperience)
	EVENT_MANAGER:RegisterForEvent( "uespLog" , EVENT_QUEST_OPTIONAL_STEP_ADVANCED, uespLog.OnQuestOptionalStepAdvanced)
	EVENT_MANAGER:RegisterForEvent( "uespLog" , EVENT_SKILL_POINTS_CHANGED, uespLog.OnSkillPointsChanged)
	
	EVENT_MANAGER:RegisterForEvent( "uespLog" , EVENT_ACTIVE_QUEST_TOOL_CHANGED, uespLog.OnQuestToolChanged)	
		
	EVENT_MANAGER:RegisterForEvent( "uespLog" , EVENT_LOOT_UPDATED, uespLog.OnLootUpdated)
	EVENT_MANAGER:RegisterForEvent( "uespLog" , EVENT_LOOT_ITEM_FAILED, uespLog.OnLootItemFailed)
	
	uespLog.Old_LootWindow_IsControlHidden = LOOT_WINDOW.control.IsControlHidden
	LOOT_WINDOW.control.IsControlHidden = uespLog.LootWindowIsControlHidden

	EVENT_MANAGER:RegisterForEvent( "uespLog" , EVENT_CLIENT_INTERACT_RESULT, uespLog.OnClientInteractResult)
	EVENT_MANAGER:RegisterForEvent( "uespLog" , EVENT_LOOT_RECEIVED, uespLog.OnLootGained)
	EVENT_MANAGER:RegisterForEvent( "uespLog" , EVENT_ANTIQUITY_DIGGING_GAME_OVER, uespLog.OnAntiquityGameOver)
	EVENT_MANAGER:RegisterForEvent( "uespLog" , EVENT_ANTIQUITY_LEAD_ACQUIRED, uespLog.OnAntiquityLeadAcquired)
	EVENT_MANAGER:RegisterForEvent( "uespLog" , EVENT_LOOT_CLOSED, uespLog.OnLootClosed)
	EVENT_MANAGER:RegisterForEvent( "uespLog" , EVENT_MONEY_UPDATE, uespLog.OnMoneyUpdate)
	EVENT_MANAGER:RegisterForEvent( "uespLog" , EVENT_INVENTORY_SINGLE_SLOT_UPDATE, uespLog.OnInventorySlotUpdate)
	--EVENT_MANAGER:RegisterForEvent( "uespLog" , EVENT_INVENTORY_ITEM_USED, uespLog.OnInventoryItemUsed)	-- No longer called?
	EVENT_MANAGER:RegisterForEvent( "uespLog" , EVENT_BUY_RECEIPT, uespLog.OnBuyReceipt)
	EVENT_MANAGER:RegisterForEvent( "uespLog" , EVENT_SELL_RECEIPT, uespLog.OnSellReceipt)
	EVENT_MANAGER:RegisterForEvent( "uespLog" , EVENT_TELVAR_STONE_UPDATE, uespLog.OnTelvarStoneUpdate)
	EVENT_MANAGER:RegisterForEvent( "uespLog" , EVENT_CURRENCY_UPDATE, uespLog.OnCurrencyUpdate)	 
	EVENT_MANAGER:RegisterForEvent( "uespLog" , EVENT_CLOSE_BANK, uespLog.OnBankClosed)
	EVENT_MANAGER:RegisterForEvent( "uespLog" , EVENT_OPEN_BANK, uespLog.OnBankOpened)
	
    EVENT_MANAGER:RegisterForEvent( "uespLog" , EVENT_LORE_BOOK_ALREADY_KNOWN, uespLog.OnLoreBookAlreadyKnown)
    EVENT_MANAGER:RegisterForEvent( "uespLog" , EVENT_LORE_BOOK_LEARNED, uespLog.OnLoreBookLearned)
	EVENT_MANAGER:RegisterForEvent( "uespLog" , EVENT_SHOW_BOOK, uespLog.OnShowBook)
	
	EVENT_MANAGER:RegisterForEvent( "uespLog" , EVENT_SKILL_RANK_UPDATE, uespLog.OnSkillRankUpdate)

	EVENT_MANAGER:RegisterForEvent( "uespLog" , EVENT_CRAFT_COMPLETED, uespLog.OnCraftCompleted)
	EVENT_MANAGER:RegisterForEvent( "uespLog" , EVENT_CRAFTING_STATION_INTERACT, uespLog.OnCraftStationInteract)
	EVENT_MANAGER:RegisterForEvent( "uespLog" , EVENT_STYLE_LEARNED, uespLog.OnStyleLearned)	
	EVENT_MANAGER:RegisterForEvent( "uespLog" , EVENT_END_CRAFTING_STATION_INTERACT, uespLog.OnEndCraftStationInteract)		
	
	EVENT_MANAGER:RegisterForEvent( "uespLog" , EVENT_ACTION_SLOTS_FULL_UPDATE, uespLog.OnActionSlotsFullUpdate)	
	EVENT_MANAGER:RegisterForEvent( "uespLog" , EVENT_ACTION_SLOT_ABILITY_SLOTTED, uespLog.OnActionSlotAbilitySlotted)	
	EVENT_MANAGER:RegisterForEvent( "uespLog" , EVENT_ACTIVE_QUICKSLOT_CHANGED, uespLog.OnActiveQuickSlotChanged)	
	EVENT_MANAGER:RegisterForEvent( "uespLog" , EVENT_ACTIVE_WEAPON_PAIR_CHANGED, uespLog.OnActiveWeaponPairChanged)	
	
	EVENT_MANAGER:RegisterForEvent( "uespLog" , EVENT_FISHING_LURE_CLEARED, uespLog.OnFishingLureCleared)	
	EVENT_MANAGER:RegisterForEvent( "uespLog" , EVENT_FISHING_LURE_SET, uespLog.OnFishingLureSet)	
	
	EVENT_MANAGER:RegisterForEvent( "uespLog" , EVENT_GUILD_SELF_JOINED_GUILD, uespLog.OnJoinedGuild)	
	EVENT_MANAGER:RegisterForEvent( "uespLog" , EVENT_GUILD_SELF_LEFT_GUILD, uespLog.OnLeftGuild)	
	EVENT_MANAGER:RegisterForEvent( "uespLog" , EVENT_TRADING_HOUSE_CONFIRM_ITEM_PURCHASE, uespLog.OnTradingHouseConfirmItemPurchase)
	EVENT_MANAGER:RegisterForEvent( "uespLog" , EVENT_OPEN_TRADING_HOUSE, uespLog.OnTradingHouseOpen)
	EVENT_MANAGER:RegisterForEvent( "uespLog" , EVENT_CLOSE_TRADING_HOUSE, uespLog.OnTradingHouseClose)
	EVENT_MANAGER:RegisterForEvent( "uespLog" , EVENT_TRADING_HOUSE_SEARCH_RESULTS_RECEIVED, uespLog.OnTradingHouseSearchResultsReceived)	-- Removed Event?
	EVENT_MANAGER:RegisterForEvent( "uespLog" , EVENT_TRADING_HOUSE_RESPONSE_RECEIVED, uespLog.OnTradingHouseResponseReceived)
	EVENT_MANAGER:RegisterForEvent( "uespLog" , EVENT_GUILD_HISTORY_RESPONSE_RECEIVED, uespLog.OnGuildHistoryResponseReceived)
	EVENT_MANAGER:RegisterForEvent( "uespLog" , EVENT_TRADING_HOUSE_CONFIRM_ITEM_PURCHASE, uespLog.OnTradingHouseConfirmPurchase)	
	EVENT_MANAGER:RegisterForEvent( "uespLog" , EVENT_TRADING_HOUSE_ERROR, uespLog.OnTradingHouseError)	
	EVENT_MANAGER:RegisterForEvent( "uespLog" , EVENT_TRADING_HOUSE_OPERATION_TIME_OUT, uespLog.OnTradingHouseTimeOut)		
	EVENT_MANAGER:RegisterForEvent( "uespLog" , EVENT_TRADING_HOUSE_SEARCH_COOLDOWN_UPDATE, uespLog.OnTradingHouseSearchCooldownUpdate)	
	--EVENT_MANAGER:RegisterForEvent( "uespLog" , EVENT_TRADING_HOUSE_STATUS_RECEIVED, uespLog.OnTradingHouseStatusReceived)	
	
	EVENT_MANAGER:RegisterForEvent( "uespLog" , EVENT_MAIL_NUM_UNREAD_CHANGED, uespLog.OnMailNumUnreadChanged)
	EVENT_MANAGER:RegisterForEvent( "uespLog" , EVENT_MAIL_OPEN_MAILBOX, uespLog.OnMailOpenMailbox)
	EVENT_MANAGER:RegisterForEvent( "uespLog" , EVENT_MAIL_READABLE, uespLog.OnMailMessageReadable)
		
		-- Note: This event is called up to 40-50 time for each kill with some weapons (Destruction Staff)
	--EVENT_MANAGER:RegisterForEvent( "uespLog" , EVENT_ACTION_SLOT_UPDATED, uespLog.OnActionSlotUpdated)	
		
	--EVENT_MANAGER:RegisterForEvent( "uespLog" , EVENT_UNIT_DESTROYED, uespLog.OnUnitDestroyed)
	--EVENT_MANAGER:RegisterForEvent( "uespLog" , EVENT_UNIT_CREATED, uespLog.OnUnitCreated)
	EVENT_MANAGER:RegisterForEvent( "uespLog" , EVENT_PLAYER_COMBAT_STATE, uespLog.OnPlayerCombatState)
	 	
	ZO_InteractWindow:UnregisterForEvent(EVENT_CHATTER_BEGIN)
	EVENT_MANAGER:RegisterForEvent( "uespLog" , EVENT_CONVERSATION_UPDATED, uespLog.OnConversationUpdated)
	EVENT_MANAGER:RegisterForEvent( "uespLog" , EVENT_QUEST_OFFERED, uespLog.OnQuestOffered)
	EVENT_MANAGER:RegisterForEvent( "uespLog" , EVENT_CHATTER_BEGIN, uespLog.OnChatterBegin)
    EVENT_MANAGER:RegisterForEvent( "uespLog" , EVENT_CHATTER_END, uespLog.OnChatterEnd)
	
	uespLog.Old_HandleChatterOptionClicked = ZO_InteractionManager.HandleChatterOptionClicked
	ZO_InteractionManager.HandleChatterOptionClicked = uespLog.HandleChatterOptionClicked
	
	EVENT_MANAGER:RegisterForEvent( "uespLog" , EVENT_RECIPE_LEARNED, uespLog.OnRecipeLearned)
	
	EVENT_MANAGER:RegisterForEvent( "uespLog" , EVENT_BEGIN_LOCKPICK, uespLog.OnBeginLockPick)
	
	--EVENT_MANAGER:RegisterForEvent( "uespLog" , EVENT_EXPERIENCE_UPDATE, uespLog.OnExperienceUpdate)
	EVENT_MANAGER:RegisterForEvent( "uespLog" , EVENT_EXPERIENCE_GAIN, uespLog.OnExperienceGain)
	EVENT_MANAGER:RegisterForEvent( "uespLog" , EVENT_ALLIANCE_POINT_UPDATE, uespLog.OnAlliancePointsUpdate)
	
	EVENT_MANAGER:RegisterForEvent( "uespLog" , EVENT_SCREENSHOT_SAVED, uespLog.OnScreenShotSaved)
		 
	EVENT_MANAGER:RegisterForEvent( "uespLog" , EVENT_COMBAT_EVENT, uespLog.OnCombatEvent)
	EVENT_MANAGER:RegisterForEvent( "uespLog" , EVENT_POWER_UPDATE, uespLog.OnPowerUpdate)
	EVENT_MANAGER:RegisterForEvent( "uespLog" , EVENT_SYNERGY_ABILITY_GAINED, uespLog.OnSynergyAbilityGained)
	EVENT_MANAGER:RegisterForEvent( "uespLog" , EVENT_SYNERGY_ABILITY_LOST, uespLog.OnSynergyAbilityLost)
	--EVENT_MANAGER:RegisterForEvent( "uespLog" , EVENT_EFFECT_CHANGED, uespLog.OnEffectChanged)		-- Is called a lot
	
	EVENT_MANAGER:RegisterForEvent( "uespLog" , EVENT_CHAT_MESSAGE_CHANNEL, uespLog.OnChatMessage)
	EVENT_MANAGER:RegisterForEvent( "uespLog" , EVENT_MAIL_TAKE_ATTACHED_ITEM_SUCCESS, uespLog.OnMailMessageTakeAttachedItem)
	EVENT_MANAGER:RegisterForEvent( "uespLog" , EVENT_MAIL_TAKE_ATTACHED_MONEY_SUCCESS, uespLog.OnMailMessageTakeAttachedMoney)
	
	EVENT_MANAGER:RegisterForEvent( "uespLog" , EVENT_JUSTICE_GOLD_PICKPOCKETED, uespLog.OnGoldPickpocketed)
	EVENT_MANAGER:RegisterForEvent( "uespLog" , EVENT_JUSTICE_GOLD_REMOVED, uespLog.OnGoldRemoved)
	EVENT_MANAGER:RegisterForEvent( "uespLog" , EVENT_JUSTICE_ITEM_PICKPOCKETED, uespLog.OnItemPickpocketed) -- Note: This event does not seem to be called
	EVENT_MANAGER:RegisterForEvent( "uespLog" , EVENT_JUSTICE_PICKPOCKET_FAILED, uespLog.OnPickpocketFailed)	
	
	EVENT_MANAGER:RegisterForEvent( "uespLog" , EVENT_ACTION_SLOT_ABILITY_USED, uespLog.OnActionSlotAbilityUsed)
	
	EVENT_MANAGER:RegisterForEvent( "uespLog" , EVENT_ARTIFACT_CONTROL_STATE, uespLog.OnArtifactControlState)
	EVENT_MANAGER:RegisterForEvent( "uespLog" , EVENT_CAPTURE_AREA_STATUS, uespLog.OnCaptureAreaStatus)
	EVENT_MANAGER:RegisterForEvent( "uespLog" , EVENT_CORONATE_EMPEROR_NOTIFICATION, uespLog.OnCoronateEmpererNotification)
	EVENT_MANAGER:RegisterForEvent( "uespLog" , EVENT_OBJECTIVE_CONTROL_STATE, uespLog.OnObjectiveControlState)
	EVENT_MANAGER:RegisterForEvent( "uespLog" , EVENT_KEEP_ALLIANCE_OWNER_CHANGED, uespLog.OnKeepAllianceOwnerChanged)
	--EVENT_MANAGER:RegisterForEvent( "uespLog" , EVENT_KEEP_RESOURCE_UPDATE, uespLog.OnKeepResourceUpdate)   -- Happens very frequently
	EVENT_MANAGER:RegisterForEvent( "uespLog" , EVENT_KEEP_UNDER_ATTACK_CHANGED, uespLog.OnKeepUnderAttack)
	EVENT_MANAGER:RegisterForEvent( "uespLog" , EVENT_KEEP_GATE_STATE_CHANGED, uespLog.OnKeepGateStateChanged)
	EVENT_MANAGER:RegisterForEvent( "uespLog" , EVENT_GUILD_KEEP_CLAIM_UPDATED, uespLog.OnGuildKeepClaimUpdated)	
	--EVENT_MANAGER:RegisterForEvent( "uespLog" , EVENT_ASSIGNED_CAMPAIGN_CHANGED, uespLog.OnAssignedCampaignChanged)		 
	--EVENT_MANAGER:RegisterForEvent( "uespLog" , EVENT_CAMPAIGN_STATE_INITIALIZED, uespLog.OnAssignedCampaignChanged)	
	EVENT_MANAGER:RegisterForEvent( "uespLog" , EVENT_CURRENT_CAMPAIGN_CHANGED, uespLog.OnAssignedCampaignChanged)	 
		
	uespLog.InstallItemTooltip()
	
	--ZO_PreHookHandler(PopupTooltip, 'OnUpdate', function() uespLog.AddStatsPopupTooltip() end)
	--ZO_PreHookHandler(PopupTooltip, 'OnHide', function() uespLog.RemoveStatsPopupTooltip() end)
	--ZO_PreHookHandler(ItemTooltip, 'OnUpdate', function() uespLog.AddStatsItemTooltip() end)
	--ZO_PreHookHandler(ItemTooltip, 'OnHide', function() uespLog.RemoveStatsItemTooltip() end)
	
	uespLog.Old_ZO_CharacterWindowStats_ShowComparisonValues = ZO_CharacterWindowStats_ShowComparisonValues
	uespLog.Old_ZO_CharacterWindowStats_HideComparisonValues = ZO_CharacterWindowStats_HideComparisonValues
	uespLog.Old_ZO_StatEntry_Keyboard_ShowComparisonValue = ZO_StatEntry_Keyboard.ShowComparisonValue
	uespLog.Old_ZO_StatEntry_Keyboard_GetDisplayValue = ZO_StatEntry_Keyboard.GetDisplayValue
		
			-- Test alchemy overrides
	uespLog.Old_ZO_InventorySlot_OnMouseEnter = ZO_InventorySlot_OnMouseEnter
	ZO_InventorySlot_OnMouseEnter = uespLog.ZO_InventorySlot_OnMouseEnter

	uespLog.Old_ZO_InventorySlot_OnMouseExit = ZO_InventorySlot_OnMouseExit
	ZO_InventorySlot_OnMouseExit = uespLog.ZO_InventorySlot_OnMouseExit	
		
	if (uespLog.GetCustomStatDisplay()) then
		if (uespLog.GetInventoryStatsConfig() == "off") then
			uespLog.SetInventoryStatsConfig("on")
		end
	end
		
	uespLog.AddCharacterWindowStats()
	uespLog.ModifyInventoryStatsWindow()
	
	uespLog.Old_IsItemUsable = IsItemUsable
	IsItemUsable = uespLog.IsItemUsable
			
	uespLog.Old_ActionButton_HandleRelease = ActionButton.HandleRelease
	ActionButton.HandleRelease = uespLog.ActionButton_HandleRelease
	
	uespLog.Old_Quit = Quit
	uespLog.Old_Logout = Logout
	uespLog.Old_ReloadUI = ReloadUI
	Quit = uespLog.Quit
	Logout = uespLog.Logout
	ReloadUI = uespLog.ReloadUI
	
	uespLog.Old_DoCommand = DoCommand
	DoCommand = uespLog.DoCommand
	CHAT_SYSTEM.commandPrefixes[47] = uespLog.DoCommand

	--uespLog.Old_ZO_Alert = ZO_Alert
	--ZO_Alert = uespLog.ZO_Alert
		
	--uespLog.Old_ZO_ChatTextEntry_Execute = ZO_ChatTextEntry_Execute
	--ZO_ChatTextEntry_Execute = uespLog.ZO_ChatTextEntry_Execute
		
	--EVENT_ARTIFACT_CONTROL_STATE(integer eventCode, string artifactName, integer keepId, string playerName, integer playerAlliance, integer controlEvent, integer controlState, integer campaignId)
	--EVENT_CAPTURE_AREA_STATUS (integer eventCode, integer keepId, integer objectiveId, integer battlegroundContext, integer capturePoolValue, integer capturePoolMax, integer capturingPlayers, integer contestingPlayers, integer 	owningAlliance)
	--EVENT_CORONATE_EMPEROR_NOTIFICATION (integer eventCode, integer campaignId, string emperorName, integer emperorAlliance)
	--EVENT_DEPOSE_EMPEROR_NOTIFICATION (integer eventCode, integer campaignId, string emperorName, integer emperorAlliance, bool abdication)
	--EVENT_FORWARD_CAMPS_UPDATED (integer eventCode)
	--EVENT_FORWARD_CAMP_RESPAWN_TIMER_BEGINS (integer durationMS)
	--EVENT_OBJECTIVE_CONTROL_STATE (integer eventCode, integer objectiveKeepId, integer objectiveObjectiveId, integer battlegroundContext, string objectiveName, integer objectiveType, integer objectiveControlEvent, integer objectiveControlState, integer objectiveParam1, integer objectiveParam2)
	--EVENT_ZONE_SCORING_CHANGED (integer eventCode)
	--EVENT_KEEPS_INITIALIZED (integer eventCode)
	--EVENT_KEEP_ALLIANCE_OWNER_CHANGED (integer eventCode, integer keepId, integer battlegroundContext, integer owningAlliance)
	--EVENT_KEEP_END_INTERACTION (integer eventCode)
	--EVENT_KEEP_GATE_STATE_CHANGED (integer eventCode, integer keepId, bool open)
	--EVENT_KEEP_GUILD_CLAIM_UPDATE (integer eventCode, integer keepId, integer battlegroundContext)
	--EVENT_KEEP_INITIALIZED (integer eventCode, integer keepId, integer battlegroundContext)
	--EVENT_KEEP_OWNERSHIP_CHANGED_NOTIFICATION (integer eventCode, integer campaignId, integer keepId, integer oldOwner, integer newOwner)
	--EVENT_KEEP_RESOURCE_UPDATE (integer eventCode, integer keepId)
	--EVENT_KEEP_START_INTERACTION (integer eventCode)
	--EVENT_KEEP_UNDER_ATTACK_CHANGED (integer eventCode, integer keepId, integer battlegroundContext, bool underAttack)
	--EVENT_END_KEEP_GUILD_CLAIM_INTERACTION (integer eventCode)
	--EVENT_END_KEEP_GUILD_RELEASE_INTERACTION (integer eventCode)
	--EVENT_START_KEEP_GUILD_CLAIM_INTERACTION (integer eventCode)
	--EVENT_START_KEEP_GUILD_RELEASE_INTERACTION (integer eventCode)
	--EVENT_GUILD_KEEP_CLAIM_UPDATED (integer eventCode, integer guildId)
		
	uespLog.Old_GenerateResearchTraitCounts = ZO_SharedSmithingResearch.GenerateResearchTraitCounts
	ZO_SharedSmithingResearch.GenerateResearchTraitCounts = uespLog.GenerateResearchTraitCounts
	
	uespLog.Old_ZO_SmithingResearchSelect_SetupDialog = ZO_SmithingResearchSelect.SetupDialog
	ZO_SmithingResearchSelect.SetupDialog = uespLog.ZO_SmithingResearchSelect_SetupDialog
		
	uespLog.fillInfoData()
	uespLog.Msg("Initialized uespLog...")
	
	--uespLog.Old_OnAddGameData = ZO_ItemIconTooltip_OnAddGameData
	--ZO_ItemIconTooltip_OnAddGameData = uespLog.new_OnAddGameData
	
	--uespLog.Old_ItemOnAddGameData = ZO_ItemIconTooltip_ItemOnAddGameData
	--ZO_ItemIconTooltip_ItemOnAddGameData = uespLog.new_ItemOnAddGameData
	
    PopupTooltip:SetHandler("OnMouseUp", uespLog.OnTooltipMouseUp)
    --self.resultTooltip:GetNamedChild("Icon"):SetHandler("OnMouseUp", uespLog.OnTooltipMouseUp)
	uespLog.Orig_ZO_LinkHandler_OnLinkMouseUp = ZO_LinkHandler_OnLinkMouseUp
	ZO_LinkHandler_OnLinkMouseUp = uespLog.ZO_LinkHandler_OnLinkMouseUp
	
	SMITHING.creationPanel.resultTooltip:SetHandler("OnMouseUp", uespLog.SmithingCreationOnTooltipMouseUp)
	SMITHING.improvementPanel.resultTooltip:SetHandler("OnMouseUp", uespLog.SmithingImprovementOnTooltipMouseUp)
	ALCHEMY.tooltip:SetHandler("OnMouseUp", uespLog.AlchemyOnTooltipMouseUp)
	ALCHEMY.tooltip:GetNamedChild("Icon"):SetHandler("OnMouseUp", uespLog.OnTooltipMouseUp)
	ENCHANTING.resultTooltip:SetHandler("OnMouseUp", uespLog.EnchantingOnTooltipMouseUp)
	ENCHANTING.resultTooltip:GetNamedChild("Icon"):SetHandler("OnMouseUp", uespLog.OnTooltipMouseUp)
	
	uespLog.Old_NotifyDeleteMailAdded = MAIL_INBOX.Delete
	MAIL_INBOX.Delete = uespLog.NotifyDeleteMailAdded 
	MAIL_INBOX:RefreshData()
	
	uespLog.SetupSlashCommands()
	
	uespLog.OriginalSetupPendingPost = TRADING_HOUSE.SetupPendingPost
		
	if (MasterMerchant ~= nil and uespLog.IsSalesShowPrices()) then
		uespLog.Old_MM_DealCalc = MasterMerchant.DealCalc
		MasterMerchant.DealCalc = uespLog.DealCalc
		
		uespLog.Old_MM_GetTradingHouseSearchResultItemInfo = MasterMerchant.AdjustGetTradingHouseSearchResultItemInfo
		MasterMerchant.AdjustGetTradingHouseSearchResultItemInfo = uespLog.GetTradingHouseSearchResultItemInfo
		
		uespLog.Old_MM_GetTradingHouseListingItemInfo = MasterMerchant.AdjustGetTradingHouseListingItemInfo
		MasterMerchant.AdjustGetTradingHouseListingItemInfo = uespLog.GetTradingHouseListingItemInfo
		
		uespLog.Old_MM_GetDealValue = MasterMerchant.GetDealValue
		MasterMerchant.GetDealValue = uespLog.GetDealValue
		
		uespLog.Old_MM_GetProfitValue = MasterMerchant.GetProfitValue
		MasterMerchant.GetProfitValue = uespLog.GetProfitValue
		
		uespLog.Old_MM_SetupPendingPost = MasterMerchant.SetupPendingPost
		MasterMerchant.SetupPendingPost = uespLog.SetupPendingPost
		--TRADING_HOUSE.SetupPendingPost = uespLog.SetupPendingPost	
		
		--MasterMerchant.updateCalc = function() end
	elseif (uespLog.IsSalesShowPrices()) then
		uespLog.Old_MM_GetTradingHouseSearchResultItemInfo = GetTradingHouseSearchResultItemInfo
		GetTradingHouseSearchResultItemInfo = uespLog.GetTradingHouseSearchResultItemInfo
		
		uespLog.Old_MM_GetTradingHouseListingItemInfo = GetTradingHouseListingItemInfo
		GetTradingHouseListingItemInfo = uespLog.GetTradingHouseListingItemInfo		
		
		TRADING_HOUSE.SetupPendingPost = uespLog.SetupPendingPost
		
		--ZO_TradingHouse_CreateListingItemData = uespLog.ZO_TradingHouse_CreateListingItemData
		--ZO_TradingHouse_CreateSearchResultItemData = uespLog.ZO_TradingHouse_CreateSearchResultItemData
	end	
	
	uespLog.UpdateKeepChatOpen()
		
	uespLog.SetupTraderControls()
		
	zo_callLater(uespLog.LoadSalePriceData, 500)
	zo_callLater(uespLog.InitTradeData, 500) 
	zo_callLater(uespLog.InitCharData, 500)
	zo_callLater(uespLog.InitCrafting, 500)
	
	QueryCampaignSelectionData()
	
	if (uespLog.savedVars.settings.data.mineTestIndex ~= nil and uespLog.savedVars.settings.data.mineTestIndex > 0) then
		zo_callLater(uespLog.ResumeMineTest, 5000)	
	end
	
end


function uespLog.SceneManager_Show(self, name)
	local timeDiff = GetTimeStamp() - uespLog.startTimeStamp

	if (name == "marketAnnouncement" and uespLog.GetCloseMarketAnnouncement() and timeDiff < uespLog.MARKET_HIDE_TIME) then
		uespLog.DebugMsg("Hiding market announcement window...")
		return 
	end
	
	return uespLog.Old_SceneManager_Show(self, name)
end


function uespLog.InitCrafting()
	local LLC = LibLazyCrafting

	if (LLC and LLC.SendCraftEvent) then
		uespLog.Old_LLCSendCraftEvent = LLC.SendCraftEvent
		LLC.SendCraftEvent = uespLog.LLCSendCraftEvent
	end
end


function uespLog.LLCSendCraftEvent(event, station, requester, returnTable)
	--uespLog.DebugMsg("LLCSendCraftEvent")
	
	if (event == LLC_CRAFT_SUCCESS or event == LLC_INITIAL_CRAFT_SUCCESS) then
		uespLog.OnCraftCompleted(event, station, true)
	end
	
	return uespLog.Old_LLCSendCraftEvent(event, station, requester, returnTable)
end


function uespLog.OnLLCCraftComplete(event, station, extraLLCResultInfo)

	uespLog.DebugMsg("OnLLCCraftComplete")
end


function uespLog.UpdateKeepChatOpen()

	if (uespLog.LastKeepChatOpen == uespLog.GetKeepChatOpen()) then
		return
	end
	
	local storeScene = SCENE_MANAGER:GetScene("store")
	local furnitureBrowserScene = SCENE_MANAGER:GetScene(HOUSING_FURNITURE_KEYBOARD_SCENE_NAME)
	local helpTutorialsScene = SCENE_MANAGER:GetScene("helpTutorials")
	local marketScene = SCENE_MANAGER:GetScene("market")
			
	if (uespLog.GetKeepChatOpen()) then
		TRADING_HOUSE_SCENE:RemoveFragment(MINIMIZE_CHAT_FRAGMENT)
		helpTutorialsScene:RemoveFragment(MINIMIZE_CHAT_FRAGMENT)
		HELP_EMOTES_SCENE:RemoveFragment(MINIMIZE_CHAT_FRAGMENT)
		storeScene:RemoveFragment(MINIMIZE_CHAT_FRAGMENT)
		furnitureBrowserScene:RemoveFragment(MINIMIZE_CHAT_FRAGMENT)
		DYE_STAMP_CONFIRMATION_KEYBOARD_SCENE:RemoveFragment(MINIMIZE_CHAT_FRAGMENT)
		CROWN_CRATE_KEYBOARD_SCENE:RemoveFragment(MINIMIZE_CHAT_FRAGMENT)
		marketScene:RemoveFragment(MINIMIZE_CHAT_FRAGMENT)
		CHAMPION_PERKS_SCENE:RemoveFragment(MINIMIZE_CHAT_FRAGMENT)
	else
		TRADING_HOUSE_SCENE:AddFragment(MINIMIZE_CHAT_FRAGMENT)
		helpTutorialsScene:AddFragment(MINIMIZE_CHAT_FRAGMENT)
		HELP_EMOTES_SCENE:AddFragment(MINIMIZE_CHAT_FRAGMENT)
		storeScene:AddFragment(MINIMIZE_CHAT_FRAGMENT)
		furnitureBrowserScene:AddFragment(MINIMIZE_CHAT_FRAGMENT)
		DYE_STAMP_CONFIRMATION_KEYBOARD_SCENE:AddFragment(MINIMIZE_CHAT_FRAGMENT)
		CROWN_CRATE_KEYBOARD_SCENE:AddFragment(MINIMIZE_CHAT_FRAGMENT)
		marketScene:AddFragment(MINIMIZE_CHAT_FRAGMENT)
		CHAMPION_PERKS_SCENE:AddFragment(MINIMIZE_CHAT_FRAGMENT)
	end
	
	uespLog.LastKeepChatOpen = uespLog.GetKeepChatOpen()
end


uespLog.Old_GetTradingHouseSearchResultItemInfo = GetTradingHouseSearchResultItemInfo
uespLog.Old_GetTradingHouseListingItemInfo = GetTradingHouseListingItemInfo
uespLog.Old_ZO_TradingHouse_CreateListingItemData = ZO_TradingHouse_CreateListingItemData
uespLog.Old_ZO_TradingHouse_CreateSearchResultItemData = ZO_TradingHouse_CreateSearchResultItemData


	--	Hook initialization onto the ADD_ON_LOADED event  
EVENT_MANAGER:RegisterForEvent("uespLog" , EVENT_ADD_ON_LOADED, uespLog.Initialize)


function uespLog.SetupSlashCommands()
	uespLog.SetSlashCommand("/uci", SLASH_COMMANDS["/uespcharinfo"])
	uespLog.SetSlashCommand("/loc", uespLog.LocateCommand)
	uespLog.SetSlashCommand("/ud", SLASH_COMMANDS["/uespd"])
	uespLog.SetSlashCommand("/ue", SLASH_COMMANDS["/uespenl"])
	uespLog.SetSlashCommand("/umi", SLASH_COMMANDS["/uespmineitems"])
	uespLog.SetSlashCommand("/uti", SLASH_COMMANDS["/uesptargetinfo"])
	uespLog.SetSlashCommand("/uri", SLASH_COMMANDS["/uespresearch"])
	uespLog.SetSlashCommand("/ucl", SLASH_COMMANDS["/uespcomparelink"])
	uespLog.SetSlashCommand("/ume", SLASH_COMMANDS["/uespmakeenchant"])
	uespLog.SetSlashCommand("/uml", SLASH_COMMANDS["/uespmakelink"])
	uespLog.SetSlashCommand("/upf", uespLog.ShowPvpFights)
	uespLog.SetSlashCommand("/ucd", SLASH_COMMANDS["/uespchardata"])
	uespLog.SetSlashCommand("/ulb", SLASH_COMMANDS["/uesplorebook"])
	uespLog.SetSlashCommand("/uqi", SLASH_COMMANDS["/uespquestitem"])
	uespLog.SetSlashCommand("/utt", SLASH_COMMANDS["/uesptreasuretimer"])
	uespLog.SetSlashCommand("/usb", uespLog.Command_SaveBuildData)
	uespLog.SetSlashCommand("/usp", SLASH_COMMANDS["/uespskillpoints"])
	uespLog.SetSlashCommand("/rl", SLASH_COMMANDS["/reloadui"])
	uespLog.SetSlashCommand("/afk", uespLog.AfkCommand)
	uespLog.SetSlashCommand("/away", uespLog.AwayCommand)
	uespLog.SetSlashCommand("/back", uespLog.BackCommand)
	uespLog.SetSlashCommand("/online", function() uespLog.AfkCommand("online") end)
	uespLog.SetSlashCommand("/offline", function() uespLog.AfkCommand("offline") end)
	uespLog.SetSlashCommand("/utl", SLASH_COMMANDS["/uesptrackloot"])
	uespLog.SetSlashCommand("/ukd", SLASH_COMMANDS["/uespkilldata"])
	uespLog.SetSlashCommand("/home", uespLog.TeleportToPrimaryHome)
	uespLog.SetSlashCommand("/umw", uespLog.MasterWritCmd)
end


function uespLog.SetSlashCommand(cmd, func)

	if (SLASH_COMMANDS[cmd] ~= nil) then
		return false
	end
	
	SLASH_COMMANDS[cmd] = func
	return true
end


function uespLog.ModifyInventoryStatsWindow()

	if (uespLog.GetInventoryStatsConfig() ~= "off") then
		ZO_CharacterWindowStats_ShowComparisonValues = uespLog.ZO_CharacterWindowStats_ShowComparisonValues
		
				-- Note: Using our function will result in a "Protected Function" error when using "E" to deposit items into the bank (?)
				-- Just use the default function which seems to have no effect of not hiding the custom stat controls.
				-- This is due to AGS overriding ZO_CharacterWindowStats_HideComparisonValues and then resetting it.
		--ZO_CharacterWindowStats_HideComparisonValues = uespLog.ZO_CharacterWindowStats_HideComparisonValues
		
		ZO_StatEntry_Keyboard.ShowComparisonValue = uespLog.ZO_StatEntry_Keyboard_ShowComparisonValue
		
		if (GetAPIVersion() > 100021) then
			ZO_StatEntry_Keyboard.GetDisplayValue = uespLog.ZO_StatEntry_Keyboard_GetDisplayValue
		end
		
	else
		ZO_CharacterWindowStats_ShowComparisonValues = uespLog.Old_ZO_CharacterWindowStats_ShowComparisonValues
		--ZO_CharacterWindowStats_HideComparisonValues = uespLog.Old_ZO_CharacterWindowStats_HideComparisonValues
		ZO_StatEntry_Keyboard.ShowComparisonValue = uespLog.Old_ZO_StatEntry_Keyboard_ShowComparisonValue
		
		if (GetAPIVersion() > 100021) then
			ZO_StatEntry_Keyboard.GetDisplayValue = uespLog.Old_ZO_StatEntry_Keyboard_GetDisplayValue
		end
	end
	
end


function uespLog.InitAutoMining ()

	if (uespLog.isAutoMiningItems and uespLog.mineItemAutoRestart) then
		
		uespLog.MsgColor(uespLog.mineColor, "UESP: Auto-resetting current log data...")
		uespLog.ClearSavedVarSection("all")
		
		if (uespLog.mineItemsAutoNextItemId > uespLog.mineItemsAutoLastItemId) then
			uespLog.isAutoMiningItems = false
			uespLog.savedVars.settings.data.isAutoMiningItems = false
			uespLog.mineItemAutoReload = false
			uespLog.savedVars.settings.data.mineItemAutoReload = false
			uespLog.mineItemAutoRestart = false
			uespLog.savedVars.settings.data.mineItemAutoRestart = false
			uespLog.MsgColor(uespLog.mineColor, "UESP: Stopped auto-mining due to reaching max ID of "..tostring(uespLog.mineItemsAutoNextItemId))
		else
			uespLog.MsgColor(uespLog.mineColor, "UESP: Auto-restarting item mining at ID "..tostring(uespLog.mineItemsAutoNextItemId).." in 10 secs...")
			zo_callLater(uespLog.MineItemsAutoLoopSafe, 10000)
			uespLog.MineItemsOutputStartLog()
			uespLog.mineItemAutoRestartOutputEnd = false
		end
	end
	
end


function uespLog.outputInitMessage ()
	EVENT_MANAGER:UnregisterForEvent("uespLog-initmsg", EVENT_PLAYER_ACTIVATED)
	
	local flagStr = uespLog.BoolToOnOff(uespLog.IsDebug())
	uespLog.Msg("uespLog v"..uespLog.version.." add-on initialized...debug output is currently "..tostring(flagStr)..".")
end


function uespLog.OnPlayerActivated(eventCode)
	zo_callLater(uespLog.LogLocationData, 500)
end


function uespLog.EnchantingOnTooltipMouseUp(control, button, upInside)
	if upInside and button == 2 then
		local link = ZO_LinkHandler_CreateChatLink(GetEnchantingResultingItemLink, ENCHANTING:GetAllCraftingBagAndSlots())
		if link ~= "" then
			ClearMenu()

			local function AddLink()
				ZO_LinkHandler_InsertLink(zo_strformat(SI_TOOLTIP_ITEM_NAME, link))
			end
			
			local function GetInfo()
				uespLog.ShowItemInfo(link)
			end

			AddMenuItem(GetString(SI_ITEM_ACTION_LINK_TO_CHAT), AddLink)
			AddMenuItem("Show Item Info", GetInfo)
			AddMenuItem("Copy Item Link", function() uespLog.CopyItemLink(link) end)
						
			if (uespLog.IsSalesShowPrices()) then
				AddMenuItem("UESP Price to Chat", function() uespLog.SalesPriceToChat(link) end)
				AddMenuItem("Goto UESP Sales..." , function() uespLog.GotoUespSalesPage(link) end)
			end
							
			ShowMenu(ENCHANTING)
		end
	end
end


function uespLog.AlchemyOnTooltipMouseUp(control, button, upInside)
	if upInside and button == 2 then
		local link = ZO_LinkHandler_CreateChatLink(GetAlchemyResultingItemLink, ALCHEMY:GetAllCraftingBagAndSlots())
		if link ~= "" then
			ClearMenu()

			local function AddLink()
				ZO_LinkHandler_InsertLink(zo_strformat(SI_TOOLTIP_ITEM_NAME, link))
			end
			
			local function GetInfo()
				uespLog.ShowItemInfo(link)
			end

			AddMenuItem(GetString(SI_ITEM_ACTION_LINK_TO_CHAT), AddLink)
			AddMenuItem("Show Item Info", GetInfo)
			AddMenuItem("Copy Item Link", function() uespLog.CopyItemLink(link) end)
						
			if (uespLog.IsSalesShowPrices()) then
				AddMenuItem("UESP Price to Chat", function() uespLog.SalesPriceToChat(link) end)
				AddMenuItem("Goto UESP Sales..." , function() uespLog.GotoUespSalesPage(link) end)
			end
				
			ShowMenu(ALCHEMY)
		end
	end
end


function uespLog.SmithingCreationOnTooltipMouseUp(control, button, upInside)
	if upInside and button == 2 then
		local patternIndex, materialIndex, materialQuantity, styleIndex, traitIndex, _ = SMITHING.creationPanel:GetAllCraftingParameters()
		local link = ZO_LinkHandler_CreateChatLink(GetSmithingPatternResultLink, patternIndex, materialIndex, materialQuantity, styleIndex, traitIndex)
		
		if link ~= "" then
			ClearMenu()

			local function AddLink()
				ZO_LinkHandler_InsertLink(zo_strformat(SI_TOOLTIP_ITEM_NAME, link))
			end
			
			local function GetInfo()
				uespLog.ShowItemInfo(link)
			end

			AddMenuItem(GetString(SI_ITEM_ACTION_LINK_TO_CHAT), AddLink)
			AddMenuItem("Show Item Info", GetInfo)
			AddMenuItem("Copy Item Link", function() uespLog.CopyItemLink(link) end)
						
			if (uespLog.IsSalesShowPrices()) then
				AddMenuItem("UESP Price to Chat", function() uespLog.SalesPriceToChat(link) end)
				AddMenuItem("Goto UESP Sales..." , function() uespLog.GotoUespSalesPage(link) end)
			end
				
			ShowMenu(SMITHING)
		end
	end
end


function uespLog.SmithingImprovementOnTooltipMouseUp(control, button, upInside)
	if upInside and button == 2 then
		local itemToImproveBagId, itemToImproveSlotIndex, craftingType = SMITHING.improvementPanel:GetCurrentImprovementParams()
		local link = GetSmithingImprovedItemLink(itemToImproveBagId, itemToImproveSlotIndex, craftingType, LINK_STYLE_BRACKETS)
		
		if link ~= "" then
			ClearMenu()

			local function AddLink()
				ZO_LinkHandler_InsertLink(zo_strformat(SI_TOOLTIP_ITEM_NAME, link))
			end
			
			local function GetInfo()
				uespLog.ShowItemInfo(link)
			end

			AddMenuItem(GetString(SI_ITEM_ACTION_LINK_TO_CHAT), AddLink)
			AddMenuItem("Show Item Info", GetInfo)
			AddMenuItem("Copy Item Link", function() uespLog.CopyItemLink(link) end)
						
			if (uespLog.IsSalesShowPrices()) then
				AddMenuItem("UESP Price to Chat", function() uespLog.SalesPriceToChat(link) end)
				AddMenuItem("Goto UESP Sales..." , function() uespLog.GotoUespSalesPage(link) end)
			end
				
			ShowMenu(SMITHING)
		end
	end
end


function uespLog.OnInventoryShowItemInfo (inventorySlot, slotActions)
	local bag, index = ZO_Inventory_GetBagAndIndex(inventorySlot)
	local itemLink = GetItemLink(bag, index, LINK_STYLE_DEFAULT)
	uespLog.ShowItemInfo(itemLink)
end


function uespLog.ZO_InventorySlot_DoPrimaryAction (inventorySlot)
    inventorySlot = GetInventorySlotComponents(inventorySlot)
    PerClickInitializeActions(inventorySlot, PREVENT_CONTEXT_MENU)
    g_slotActions:DoPrimaryAction()
end


function uespLog.New_InventorySlot_ShowContextMenu (inventorySlot)
	PerClickInitializeActions(inventorySlot, USE_CONTEXT_MENU)
    g_slotActions:Show()
	--g_slotActions:AddSlotAction("Show Item Info", uespLog.OnInventoryShowItemInfo, "primary")
	--uespLog.Old_InventorySlot_ShowContextMenu(inventorySlot)
end


function uespLog.CopyItemLinkDialog_OnKeyUp(key, ctrl, alt, shift, command)
end


function uespLog.CopyItemLinkDialog_Close()
	uespCopyItemLinkDialog:SetHidden(true)
end


function uespLog.CopyItemLink(itemLink)
	uespCopyItemLinkDialogTitle:SetText("UESP -- Copy Item Link")
	uespCopyItemLinkDialogLabel:SetText("Press CTRL+C to copy the item link and ESC/Click to exit:")
	uespCopyItemLinkDialogNoteEdit:SetText(itemLink)
	uespCopyItemLinkDialog:SetHidden(false)
	uespCopyItemLinkDialogNoteEdit:SetEditEnabled(false)
	
	zo_callLater(function() uespCopyItemLinkDialogNoteEdit:SelectAll() end, 250)
	 uespCopyItemLinkDialogNoteEdit:SelectAll()
end


function uespLog.OnTooltipMouseUp (control, button, upInside)

	if upInside and button == 2 then
		local link = PopupTooltip.lastLink
		
		if (link ~= "") then
			PopupTooltip:GetOwningWindow():SetDrawTier(ZO_Menus:GetDrawTier() - 1)
			ClearMenu()

			local function AddLink()
				ZO_LinkHandler_InsertLink(zo_strformat(SI_TOOLTIP_ITEM_NAME, link))
			end
			
			local function GetInfo()
				uespLog.ShowItemInfo(link)
			end
			
			AddMenuItem(GetString(SI_ITEM_ACTION_LINK_TO_CHAT), AddLink)
			AddMenuItem("Show Item Info", GetInfo)
			AddMenuItem("Copy Item Link", function() ZO_PopupTooltip_Hide() uespLog.CopyItemLink(link) end)
						
			if (uespLog.IsSalesShowPrices()) then
				AddMenuItem("UESP Price to Chat", function() ZO_PopupTooltip_Hide() uespLog.SalesPriceToChat(link) end)
				AddMenuItem("Goto UESP Sales..." , function() ZO_PopupTooltip_Hide() uespLog.GotoUespSalesPage(link) end)
			end
				
			ShowMenu(PopupTooltip)
		end
	end
	
end


function uespLog.ZO_LinkHandler_OnLinkMouseUp (link, button, control)

    if (type(link) == 'string' and #link > 0) then
		local handled = LINK_HANDLER:FireCallbacks(LINK_HANDLER.LINK_MOUSE_UP_EVENT, link, button, ZO_LinkHandler_ParseLink(link))
		
		if (not handled) then
            uespLog.Orig_ZO_LinkHandler_OnLinkMouseUp(link, button, control)
			
            if (button == 2 and link ~= '') then
				AddMenuItem("Show Item Info", function() uespLog.ShowItemInfo(link) end)
				AddMenuItem("Copy Item Link", function() ZO_PopupTooltip_Hide() uespLog.CopyItemLink(link) end)
								
				if (uespLog.IsSalesShowPrices()) then
					AddMenuItem("UESP Price to Chat", function() ZO_PopupTooltip_Hide() uespLog.SalesPriceToChat(link) end)
					AddMenuItem("Goto UESP Sales..." , function() ZO_PopupTooltip_Hide() uespLog.GotoUespSalesPage(link) end)
				end
				
                ShowMenu(control)
            end
        end
    end
	
end


function uespLog.FindDataIndexFromHorizontalList (scrollListControl, rootList, dataName, defaultIndex)
	local selIndex = nil
	local control

	for i, control in ipairs(rootList.controls) do
		if scrollListControl == control then
			selIndex = 1 - ((rootList.selectedIndex or 0) - (i - rootList.halfNumVisibleEntries - 1))
		
			if (dataName ~= nil and control[dataName] ~= nil) then
				return control[dataName]
			end
			
			return selIndex
		end
	end
	
	return defaultIndex
end


function uespLog.GetItemLinkRowControl (rowControl)
	local dataEntry = rowControl.dataEntry
	local bagId, slotIndex 
	local itemLink = nil
	local storeMode = uespLog.GetStoreMode()
	--SI_STORE_MODE_REPAIR SI_STORE_MODE_BUY_BACK SI_STORE_MODE_BUY  SI_STORE_MODE_SELL
	
	if (dataEntry ~= nil and dataEntry.data ~= nil and dataEntry.data.slotIndex ~= nil) then
		slotIndex = dataEntry.data.slotIndex
		bagId = dataEntry.data.bagId
	
		if (storeMode == SI_STORE_MODE_BUY_BACK) then
			itemLink = GetBuybackItemLink(slotIndex, LINK_STYLE_DEFAULT)	
		elseif (storeMode == SI_STORE_MODE_BUY) then
			itemLink = GetStoreItemLink(slotIndex, LINK_STYLE_DEFAULT)	
		elseif (bagId == nil) then
			itemLink = GetTradingHouseSearchResultItemLink(slotIndex)
		else
			itemLink = GetItemLink(bagId, slotIndex, LINK_STYLE_DEFAULT)
		end
		
	elseif (dataEntry ~= nil and dataEntry.data ~= nil and dataEntry.data.bag ~= nil) then
		bagId = dataEntry.data.bag
		slotIndex = dataEntry.data.index 
		itemLink = GetItemLink(bagId, slotIndex, LINK_STYLE_DEFAULT)
	elseif (rowControl.bagId ~= nil and rowControl.itemIndex ~= nil) then
		bagId = rowControl.bagId
		slotIndex = rowControl.itemIndex
		itemLink = GetItemLink(bagId, slotIndex, LINK_STYLE_DEFAULT)
	elseif (rowControl.bagId ~= nil and rowControl.slotIndex ~= nil) then
		bagId = rowControl.bagId
		slotIndex = rowControl.slotIndex
		itemLink = GetItemLink(bagId, slotIndex, LINK_STYLE_DEFAULT)
	elseif (dataEntry ~= nil and dataEntry.data ~= nil and dataEntry.data.lootId ~= nil) then
		slotIndex = dataEntry.data.lootId
		itemLink = GetLootItemLink(slotIndex, LINK_STYLE_DEFAULT)
	elseif (rowControl.slotIndex ~= nil) then
		slotIndex = rowControl.slotIndex
		itemLink = GetLootItemLink(slotIndex, LINK_STYLE_DEFAULT)
	else
		local parents = { }
		local parentNames = {} 
		local i
		
		parents[0] = rowControl
		
		for i = 1, 6 do
			if (parents[i-1] == nil) then
				parents[i] = nil
			else
				parents[i] = parents[i-1]:GetParent()
			end
		end
		
		for i = 0, 6 do
			if (parents[i] == nil) then
				parentNames[i] = ""
			else
				parentNames[i] = parents[i]:GetName()
			end
		end
		
		if (parentNames[3] == "ZO_SmithingTopLevelCreationPanelPatternList") then
			local patternIndex, materialIndex, materialQuantity, styleIndex, traitIndex = SMITHING.creationPanel:GetAllCraftingParameters()
			patternIndex = uespLog.FindDataIndexFromHorizontalList(rowControl, SMITHING.creationPanel.patternList, nil, patternIndex)
			itemLink = GetSmithingPatternResultLink(patternIndex, materialIndex, materialQuantity, styleIndex, traitIndex)
		elseif (parentNames[3] == "ZO_SmithingTopLevelCreationPanelMaterialList") then
			local patternIndex, materialIndex, materialQuantity, styleIndex, traitIndex = SMITHING.creationPanel:GetAllCraftingParameters()			
			materialIndex = uespLog.FindDataIndexFromHorizontalList(rowControl, SMITHING.creationPanel.materialList, "materialIndex", materialIndex)
			itemLink = GetSmithingPatternMaterialItemLink(patternIndex, materialIndex)
		elseif (parentNames[3] == "ZO_SmithingTopLevelCreationPanelStyleList") then
			local patternIndex, materialIndex, materialQuantity, styleIndex, traitIndex = SMITHING.creationPanel:GetAllCraftingParameters()			
			styleIndex = uespLog.FindDataIndexFromHorizontalList(rowControl, SMITHING.creationPanel.styleList, "styleIndex", styleIndex)
			itemLink = GetSmithingStyleItemLink(styleIndex)
		elseif (parentNames[3] == "ZO_SmithingTopLevelCreationPanelTraitList") then
			local patternIndex, materialIndex, materialQuantity, styleIndex, traitIndex = SMITHING.creationPanel:GetAllCraftingParameters()			
			traitIndex = uespLog.FindDataIndexFromHorizontalList(rowControl, SMITHING.creationPanel.traitList, "traitIndex", traitIndex)
			itemLink = GetSmithingTraitItemLink(traitIndex)
		elseif (parentNames[0] == "ZO_SmithingTopLevelImprovementPanelSlotContainerBoosterSlot") then
			local itemToImproveBagId, itemToImproveSlotIndex, craftingType = SMITHING.improvementPanel:GetCurrentImprovementParams()
			itemLink = GetSmithingImprovementItemLink(craftingType, SMITHING.improvementPanel:GetBoosterRowForQuality(SMITHING.improvementPanel.currentQuality).index)
		elseif (parentNames[0] == "ZO_SmithingTopLevelImprovementPanelSlotContainerImprovementSlot") then
			local itemToImproveBagId, itemToImproveSlotIndex, craftingType = SMITHING.improvementPanel:GetCurrentImprovementParams()
			itemLink = GetItemLink(itemToImproveBagId, itemToImproveSlotIndex)
		elseif (parentNames[1] == "ZO_SmithingTopLevelRefinementPanel") then
			if (SMITHING.refinementPanel.extractionSlot.bagId == nil) then
				return
			end
			itemLink = GetItemLink(SMITHING.refinementPanel.extractionSlot.bagId, SMITHING.refinementPanel.extractionSlot.slotIndex)
		elseif (parentNames[1] == "ZO_SmithingTopLevelDeconstructionPanel") then
			if (SMITHING.deconstructionPanel.extractionSlot.bagId == nil) then
				return
			end
			itemLink = GetItemLink(SMITHING.deconstructionPanel.extractionSlot.bagId, SMITHING.deconstructionPanel.extractionSlot.slotIndex)
		end				
		
	end
	
	return itemLink
end
	
	
function uespLog.ShowItemInfoRowControl (rowControl)
	local itemLink = uespLog.GetItemLinkRowControl(rowControl)

	if (itemLink == nil) then
		uespLog.DebugMsg("UESP: ShowItemInfoRowControl -- No itemLink found!")
		return
	end
	
	uespLog.ShowItemInfo(itemLink)
end


function uespLog.CopyItemLinkRowControl (rowControl)
	local itemLink = uespLog.GetItemLinkRowControl(rowControl)

	if (itemLink == nil) then
		return
	end
	
	uespLog.CopyItemLink(itemLink)
end


function uespLog.GetWeaponTypeStr(weaponType)
	return GetString(SI_WEAPONTYPE0 + weaponType) or "Unknown"
end


function uespLog.GetArmorTypeStr(armorType)
	return GetString(SI_ARMORTYPE0 + armorType) or "Unknown"
end


function uespLog.GetItemTypeStr(itemType)
	 return GetString(SI_ITEMTYPE0 + itemType) or "Unknown"
end


function uespLog.ShowItemInfo (itemLink)
	local icon, sellPrice, meetsUsageRequirement, equipType, itemStyle = GetItemLinkInfo(itemLink)
	local itemName, itemColor, itemId, itemLevel, itemData, itemNiceName, itemNiceLink = uespLog.ParseLinkID(itemLink)
	local styleStr = GetItemStyleName(itemStyle)
	local equipTypeStr = uespLog.GetItemEquipTypeStr(equipType)
	local weaponType = GetItemLinkWeaponType(itemLink)
	local armorType = GetItemLinkArmorType(itemLink)
	
	itemName = GetItemLinkName(itemLink)
	
	local itemType, specialItemType = GetItemLinkItemType(itemLink)
	local weaponPower = GetItemLinkWeaponPower(itemLink)
	local armorRating = GetItemLinkArmorRating(itemLink, false)
	local reqLevel = GetItemLinkRequiredLevel(itemLink)
	local reqCP = GetItemLinkRequiredChampionPoints(itemLink)
	local value = GetItemLinkValue(itemLink, false)
	local condition = GetItemLinkCondition(itemLink)
	local hasArmorDecay = DoesItemLinkHaveArmorDecay(itemLink)
	local maxCharges = GetItemLinkMaxEnchantCharges(itemLink)
	local numCharges = GetItemLinkNumEnchantCharges(itemLink)
	local hasCharges = DoesItemLinkHaveEnchantCharges(itemLink)
	local hasEnchant, enchantHeader, enchantDesc = GetItemLinkEnchantInfo(itemLink)
	local hasUseAbility, useAbilityHeader, useAbilityDesc, useAbilityCooldown = GetItemLinkOnUseAbilityInfo(itemLink)
	local trait, traitText = GetItemLinkTraitInfo(itemLink)
	local isSetItem, setName, numSetBonuses, numSetEquipped, maxSetEquipped = GetItemLinkSetInfo(itemLink)
	--local setBonusRequired, setBonusDesc = GetItemLinkSetBonusInfo(itemLink)
	local flavourText = GetItemLinkFlavorText(itemLink)
	local isCrafted = IsItemLinkCrafted(itemLink)
	local isVendorTrash = IsItemLinkVendorTrash(itemLink)
	local maxSiegeHP = GetItemLinkSiegeMaxHP(itemLink)
	local siegeType = GetItemLinkSiegeType(itemLink)
	local quality = GetItemLinkDisplayQuality(itemLink)
	local isUnique = IsItemLinkUnique(itemLink)
	local isUniqueEquipped = IsItemLinkUniqueEquipped(itemLink)
	local equipType1 = GetItemLinkEquipType(itemLink)
	local isConsumable = IsItemLinkConsumable(itemLink)
	local craftSkill = GetItemLinkCraftingSkillType(itemLink)
	local isRune = IsItemLinkEnchantingRune(itemLink)
	local runeType = GetItemLinkEnchantingRuneClassification(itemLink)
	local runeRank = GetItemLinkRequiredCraftingSkillRank(itemLink)		
	local isBound = IsItemLinkBound(itemLink)
	local bindType = GetItemLinkBindType(itemLink)
	local glyphMinLevel, glyphMinCP = GetItemLinkGlyphMinLevels(itemLink)
	local bookTitle = GetItemLinkBookTitle(itemLink)
	local isBookKnown = IsItemLinkBookKnown(itemLink)
	local craftSkillRank = GetItemLinkRequiredCraftingSkillRank(itemLink)
	local recipeQuality = GetItemLinkRecipeQualityRequirement(itemLink)
	local resultItemLink = GetItemLinkRecipeResultItemLink(itemLink)
	local refinedItemLink = GetItemLinkRefinedMaterialItemLink(itemLink)
	local materialLevelDescription = GetItemLinkMaterialLevelDescription(itemLink)
	local researchIndex = uespLog.CheckIsItemLinkResearchable(itemLink)
	
	local flagString = ""
	local levelString = ""
	local glyphLevelString = ""
	
	if (hasEnchant) then flagString = flagString.."Enchant  " end
	if (isSetItem) then flagString = flagString.."Set  " end
	if (isCrafted) then flagString = flagString.."Crafted  " end
	if (isVendorTrash) then flagString = flagString.."Vendor  " end
	if (hasArmorDecay) then flagString = flagString.."ArmorDecay  " end
	if (isUnique) then flagString = flagString.."Unique  " end
	if (isUniqueEquipped) then flagString = flagString.."UniqueEquip  " end
	if (isConsumable) then flagString = flagString.."Consumable  " end
	if (isBound) then flagString = flagString.."Bound  " end
	if (siegeType > 0) then flagString = flagString.."Siege  " end
	if (hasUseAbility) then flagString = flagString.."UseAbility  " end
	
	uespLog.MsgColor(uespLog.itemColor, "Information for "..tostring(itemNiceLink))
	uespLog.MsgColor(uespLog.itemColor, ".    Data: "..tostring(itemData))
	uespLog.MsgColor(uespLog.itemColor, ".    Type: ".. uespLog.GetItemTypeStr(itemType) .." ("..tostring(itemType).." / "..tostring(specialItemType)..")      Equip: "..equipTypeStr.." ("..tostring(equipType)..")")
	
	if (glyphMinLevel ~= nil) then
		glyphLevelString = tostring(glyphMinLevel)
	elseif (glyphMinCP ~= nil) then
		glyphLevelString = "CP"..tostring(glyphMinCP)
	else
		glyphLevelString = "?"
	end
	
	if (weaponType > 0) then
		uespLog.MsgColor(uespLog.itemColor, ".     Weapon: "..uespLog.GetWeaponTypeStr(weaponType).." ("..tostring(weaponType)..")     Power: "..tostring(weaponPower).."    Glyphs: "..glyphLevelString)
	elseif (armorType > 0) then
		uespLog.MsgColor(uespLog.itemColor, ".     Armor: "..uespLog.GetArmorTypeStr(armorType).." ("..tostring(armorType)..")     Rating: "..tostring(armorRating).."    Glyphs: "..glyphLevelString)
	elseif (glyphLevelString ~= "") then
		uespLog.MsgColor(uespLog.itemColor, ".     Glyphs: "..glyphLevelString)
	end
		
	if (flagString ~= "") then
		uespLog.MsgColor(uespLog.itemColor, ".    Flags: "..flagString)
	end
	
	if (reqCP ~= nil and reqCP > 0) then
		levelString = "CP"..tostring(reqCP)
	elseif (reqLevel ~= nil) then
		levelString = tostring(reqLevel)
	end
	
	if (traitText ~= "") then
		traitText = ", " .. tostring(traitText)
	end
	
	local tagString = ""
	
	if (GetItemLinkNumItemTags ~= nil) then
		local tagCount = GetItemLinkNumItemTags(itemLink)
		
		for i = 1, tagCount do
			local tagDesc = GetItemLinkItemTagDescription(itemLink, i)
			
			if (i > 1) then
				tagString = tagString .. ", "
			end
			
			tagString = tagString .. tagDesc
		end
	end
	
	uespLog.MsgColor(uespLog.itemColor, ".    Level: "..levelString.."     Value: "..tostring(value).."     Condition: "..tostring(condition).."     Quality: "..tostring(quality))
	uespLog.MsgColor(uespLog.itemColor, ".    Style: "..styleStr.." ("..tostring(itemStyle)..")     Trait: "..uespLog.GetItemTraitName(trait).." ("..tostring(trait)..") "..tostring(traitText))
	uespLog.MsgColor(uespLog.itemColor, ".    Icon: "..tostring(icon))
	
	if (hasCharges) then
		uespLog.MsgColor(uespLog.itemColor, ".    Charges: "..tostring(numCharges).." / "..tostring(maxCharges))
	end
		
	if (hasEnchant) then
		uespLog.MsgColor(uespLog.itemColor, ".    Enchant: "..tostring(enchantHeader).." -- "..tostring(enchantDesc))
	end
	
	if (hasUseAbility) then
		uespLog.MsgColor(uespLog.itemColor, ".    UseAbility: "..tostring(useAbilityHeader).." -- "..tostring(useAbilityDesc).."     Cooldown: "..tostring(useAbilityCooldown/1000).." sec")
	end
	
	local traitAbilityCount = 0
	
	for i = 1, GetMaxTraits() do
		local hasTraitAbility, traitAbilityDescription, traitCooldown = GetItemLinkTraitOnUseAbilityInfo(itemLink, i)
		
		if (hasTraitAbility) then
			traitAbilityCount = traitAbilityCount + 1
			uespLog.MsgColor(uespLog.itemColor, ".    TraitAbility" .. tostring(traitAbilityCount) .. ": "..tostring(traitAbilityDescription).."   Cooldown: "..tostring(traitCooldown/1000).." sec")
		end
	end
	
	if (isSetItem) then
		uespLog.MsgColor(uespLog.itemColor, ".    Set: "..tostring(setName).."   Bonuses: "..tostring(numSetBonuses).." ("..tostring(numSetEquipped).." / "..tostring(maxSetEquipped).." equipped)")
		local i
		
		for i = 1, numSetBonuses do
			local setBonusRequired, setBonusDesc = GetItemLinkSetBonusInfo(itemLink, NOT_EQUIPPED, i)
			uespLog.MsgColor(uespLog.itemColor, ".       "..tostring(setBonusRequired)..": "..tostring(setBonusDesc))
		end
	end
	
	if (craftSkill == nil or craftSkill <= 0) then
		craftSkill = GetItemLinkRecipeCraftingSkillType(itemLink)
	end
	
	if (craftSkill ~= nil and craftSkill > 0) then
		uespLog.MsgColor(uespLog.itemColor, ".    Craft: "..tostring(craftSkill).."   Rank: "..tostring(craftSkillRank))
	end

	if (GetItemLinkRecipeNumTradeskillRequirements ~= nil) then
		local numTradeskills = GetItemLinkRecipeNumTradeskillRequirements(itemLink)

		if (numTradeskills > 0) then
			for i = 1, numTradeskills do
				local tradeskill, reqLevel = GetItemLinkRecipeTradeskillRequirement(itemLink, i)
				uespLog.MsgColor(uespLog.itemColor, ".    Requires: "..GetCraftingSkillName(tradeskill).." "..tostring(reqLevel))
			end
		end
		
	elseif (GetItemLinkRecipeRankRequirement ~= nil) then
		recipeRank = GetItemLinkRecipeRankRequirement(itemLink)
		uespLog.MsgColor(uespLog.itemColor, ".    Recipe Rank: "..tostring(recipeRank))
	end
	
	if (recipeQuality ~= nil and recipeQuality > 0) then
		uespLog.MsgColor(uespLog.itemColor, ".    Recipe Quality: "..tostring(recipeQuality))
	end
	
	if (resultItemLink ~= nil and resultItemLink ~= "") then
		uespLog.MsgColor(uespLog.itemColor, ".    Recipe Result: "..tostring(resultItemLink))
	end

	if (refinedItemLink ~= nil and refinedItemLink ~= "") then
		uespLog.MsgColor(uespLog.itemColor, ".    Refined Item: "..tostring(refinedItemLink))
	end
	
	local numIngredients = GetItemLinkRecipeNumIngredients(itemLink)
	
	if (numIngredients ~= nil) then
		for i = 1, numIngredients do
			local ingredientName, numOwned, numReq = GetItemLinkRecipeIngredientInfo(itemLink, i)
			if (numReq == nil) then numReq = 1 end
			uespLog.MsgColor(uespLog.itemColor, ".    Ingredient "..tostring(i)..":  "..tostring(ingredientName).." x"..tostring(numReq))
		end
	end
		
	if (runeType ~= nil and runeType > 0) then
		uespLog.MsgColor(uespLog.itemColor, ".    Rune: "..tostring(runeType).."   Rank: "..tostring(runeRank))
	end
	
	if (bindType ~= nil and bindType > 0) then
		uespLog.MsgColor(uespLog.itemColor, ".    Bind: "..tostring(bindType))
	end
	
	if (bookTitle ~= nil or itemType == 8) then
		uespLog.MsgColor(uespLog.itemColor, ".    Book: "..tostring(bookTitle).."    Known: "..tostring(isBookKnown))
	end
	
	if (siegeType ~= nil and siegeType > 0 and maxSiegeHP > 0) then
		uespLog.MsgColor(uespLog.itemColor, ".    SiegeType: "..tostring(siegeType).."   SiegeHP: "..tostring(maxSiegeHP))
	end
	
	if (materialLevelDescription ~= nil and materialLevelDescription ~= "") then
		uespLog.MsgColor(uespLog.itemColor, ".    Material Level: "..tostring(materialLevelDescription))
	end
	
	if (tagString ~= "") then
		uespLog.MsgColor(uespLog.itemColor, ".    Tags: "..tostring(tagString))
	end
	
	if (itemType == ITEMTYPE_FURNISHING) then
		local furnDataID = GetItemLinkFurnitureDataId(itemLink)
		local furnCate, furnSubCate = GetFurnitureDataCategoryInfo(furnDataID)
		local furnCateName = GetFurnitureCategoryName(furnCate)
		local furnSubCateName = GetFurnitureCategoryName(furnSubCate)
		uespLog.MsgColor(uespLog.itemColor, ".    Furniture: "..tostring(furnCateName).." / "..tostring(furnSubCateName))
	end
		
	if (flavourText ~= "") then
		uespLog.MsgColor(uespLog.itemColor, ".    Description: "..tostring(flavourText))
	end
	
end


function uespLog.new_ItemOnAddGameData (tooltipControl, gameDataType, ...)
	local data = {...}
	
	for i = 1, #data do
		uespLog.DebugMsg(".  "..tostring(i)..") "..tostring(data[i]))
	end
	
	uespLog.Old_ItemOnAddGameData(tooltipControl, gameDataType, unpack(data))
end


function uespLog.new_OnAddGameData (tooltipControl, gameDataType, ...)
	local data = {...}
	
	for i = 1, #data do
		uespLog.DebugMsg(".  "..tostring(i)..") "..tostring(data[i]))
	end
	
	uespLog.Old_OnAddGameData(tooltipControl, gameDataType, unpack(data))
end


function uespLog.fillInfoData ()
	local data = uespLog.savedVars["info"].data
	
	data["uespLogVersion"] = uespLog.version
	data["apiVersion"] = GetAPIVersion() 
	data["version"] = _VERSION
	data["language"] = GetCVar("language.2")
	
	local charName = GetUnitName("player")
	local serverCharName = GetUniqueNameForCharacter(charName)
	data["accountName"] = GetDisplayName()
	data["serverCharName"] = serverCharName
	data["characterName"] = charName
	data["server"] = GetWorldName()
	
	data["startGameTime"] = uespLog.startGameTime
	data["startTimeStamp"] = uespLog.startTimeStamp
	data["startTimeStampStr"] = GetDateStringFromTimestamp(uespLog.startTimeStamp)
end


function uespLog.HandleChatterOptionClicked (self, label)
	--uespLog.DebugExtraMsg("UESP: HandleChatterOptionClicked")
	--uespLog.DebugExtraMsg("Index:"..tostring(label.optionIndex))
	--uespLog.DebugExtraMsg("Text:"..tostring(label:GetText()))
	--uespLog.DebugExtraMsg("Type:"..tostring(label.optionType))
	
	uespLog.lastConversationOption.Text = label:GetText()
	uespLog.lastConversationOption.Type = label.optionType
	uespLog.lastConversationOption.Gold = label.gold
	uespLog.lastConversationOption.Index = label.optionIndex
	uespLog.lastConversationOption.Important = label.isImportant
		--label.chosenBefore
		
	uespLog.Old_HandleChatterOptionClicked(self, label)
end


function uespLog.OnQuestOffered (eventCode)
    local dialog, response = GetOfferedQuestInfo()
    local _, farewell = GetChatterFarewell()
	local logData = { }
	
	if (farewell == "") then farewell = GetString(SI_GOODBYE) end
	
	logData.event = "QuestOffered"
	logData.farewell = farewell
	logData.dialog = dialog
	logData.response = response
	logData.optionText = uespLog.lastConversationOption.Text
	logData.optionType = uespLog.lastConversationOption.Type
	logData.optionGold = uespLog.lastConversationOption.Gold
	logData.optionIndex = uespLog.lastConversationOption.Index
	logData.optionImp = uespLog.lastConversationOption.Important
	
	uespLog.AppendDataToLog("all", logData, uespLog.currentConversationData, uespLog.GetTimeData())
	
	uespLog.DebugExtraMsg("UESP: Updated Conversation (QuestOffered)...")
	--uespLog.DebugExtraMsg("UESP: dialog = "..tostring(dialog))
	--uespLog.DebugExtraMsg("UESP: response = "..tostring(response))
	--uespLog.DebugExtraMsg("UESP: farewell = "..tostring(farewell))	
end


function uespLog.OnConversationUpdated (eventCode, conversationBodyText, conversationOptionCount)

	local logData = { }
	
	uespLog.DebugExtraMsg("UESP: Updated conversation START...")

	logData.event = "ConversationUpdated"
	logData.bodyText = conversationBodyText
	logData.optionCount = conversationOptionCount
	
	uespLog.AppendDataToLog("all", logData, uespLog.currentConversationData, uespLog.GetTimeData())
	
	for i = 1, conversationOptionCount do
		logData = { }
		
		logData.event = "ConversationUpdated::Option"
		logData.option, logData.type, logData.optArg, logData.isImportant, logData.chosenBefore = GetChatterOption(i)
		
		uespLog.AppendDataToLog("all", logData)
	end
	
	uespLog.DebugExtraMsg("UESP: Updated conversation...")
	
	uespLog.lastConversationOption.Text = ""
	uespLog.lastConversationOption.Type = ""
	uespLog.lastConversationOption.Gold = ""
	uespLog.lastConversationOption.Index = ""
	uespLog.lastConversationOption.Important = ""	
end


function uespLog.OnChatterEnd (eventCode)
	uespLog.currentConversationData.npcName = ""
    uespLog.currentConversationData.npcLevel = ""
    uespLog.currentConversationData.x = ""
    uespLog.currentConversationData.y = ""
    uespLog.currentConversationData.zone = ""
	uespLog.currentConversationData.worldx = ""
    uespLog.currentConversationData.worldy = ""
	uespLog.currentConversationData.worldz = ""
    uespLog.currentConversationData.worldzoneid = ""
	
	uespLog.lastConversationOption.Text = ""
	uespLog.lastConversationOption.Type = ""
	uespLog.lastConversationOption.Gold = ""
	uespLog.lastConversationOption.Index = ""
	uespLog.lastConversationOption.Important = ""
end


function uespLog.OnChatterBegin (eventCode, optionCount)
	local x, y, heading, zone = uespLog.GetUnitPosition("interact")
    local npcLevel = GetUnitLevel("interact")
	local npcName = GetUnitName("interact")
	local logData = { }
	local ChatterGreeting = GetChatterGreeting()
	
	uespLog.lastConversationOption.Text = ""
	uespLog.lastConversationOption.Type = ""
	uespLog.lastConversationOption.Gold = ""
	uespLog.lastConversationOption.Index = ""
	uespLog.lastConversationOption.Important = ""
		
	if (x == nil) then
		x, y, heading, zone = uespLog.GetPlayerPosition()
	end
	
	if (npcLevel == nil) then
		npcLevel = ""
	end
	
    uespLog.currentConversationData.npcName = npcName
    uespLog.currentConversationData.npcLevel = npcLevel
    uespLog.currentConversationData.x = x
    uespLog.currentConversationData.y = y
    uespLog.currentConversationData.zone = zone
	
	if (GetUnitRawWorldPosition ~= nil) then
		uespLog.currentConversationData.worldzoneid, uespLog.currentConversationData.worldx, uespLog.currentConversationData.worldy, uespLog.currentConversationData.worldz = GetUnitRawWorldPosition("player")
	end
		
	logData.event = "ChatterBegin"
	logData.bodyText = ChatterGreeting
	logData.optionCount = optionCount
	--logData.chatText, logData.numOptions, logData.atGreeting = GetChatterData()   -- Has an issue with facial animations not showing up in the initial dialog.
		
	uespLog.AppendDataToLog("all", logData, uespLog.currentConversationData, uespLog.GetTimeData())
	
	for i = 1, optionCount do
		logData = { }
		
		logData.event = "ChatterBegin::Option"
		logData.option, logData.type, logData.optArg, logData.isImportant, logData.chosenBefore = GetChatterOption(i)
		
		uespLog.AppendDataToLog("all", logData)
	end
	
	uespLog.DebugExtraMsg("UESP: Chatter begin...")
	
		-- Manually call the original function to update the chat window.
		-- If you don't call these the NPC dialog window doesn't show up.
	INTERACTION:InitializeInteractWindow(ChatterGreeting)
	INTERACTION:UpdateChatterOptions(optionCount, false)
	--INTERACTION.optionCount, INTERACTION.importantOptions = INTERACTION:PopulateChatterOptions(optionCount, false)
	        
end


function uespLog.OnBeginLockPick (eventCode)
	local logData = { }
	
	logData.event = "LockPick"
	logData.quality = GetLockQuality()
	
	uespLog.AppendDataToLog("all", logData, uespLog.GetPlayerPositionData(), uespLog.GetTimeData())
	 
	uespLog.DebugExtraMsg("UESP: Found lock of quality "..tostring(logData.quality))
end


function uespLog.OnShowBook (eventCode, bookTitle, body, medium, showTitle, bookId)
	local logData = { }
	local diffTime = GetGameTimeMilliseconds() - uespLog.LastLoreBookTime
	
	--uespLog.DebugMsg("ShowBook: "..tostring(bookTitle)..", " .. tostring(bookId))
	
	logData.event = "ShowBook"
	logData.bookTitle = bookTitle
	logData.body = body
	logData.medium = medium
	logData.bookId = bookId
	logData.categoryIndex, logData.collectionIndex, logData.bookIndex = GetLoreBookIndicesFromBookId(bookId)
	
	uespLog.AppendDataToLog("all", logData, uespLog.GetPlayerPositionData(), uespLog.GetTimeData())
	
	if (uespLog.LastLoreBookTitle == bookTitle and diffTime < 1000) then
		uespLog.LastLoreBookTitle = ""
		uespLog.LastLoreBookTime = 0
		return
	end
	
	if (logData.collectionIndex ~= nil and logData.categoryIndex ~= nil) then
		local name2 = GetLoreCollectionInfo(logData.categoryIndex, logData.collectionIndex)
		local name1 = GetLoreCategoryInfo(logData.categoryIndex)

		uespLog.MsgType(uespLog.MSG_OTHER, "UESP: Book "..bookTitle.." ("..tostring(name1)..":"..tostring(name2)..")")
	else
		uespLog.MsgType(uespLog.MSG_OTHER, "UESP: Book "..bookTitle.." (unknown collection)")
	end
	
	uespLog.LastLoreBookTitle = ""
	uespLog.LastLoreBookTime = 0
end


function uespLog.OnLoreBookAlreadyKnown (eventCode, bookTitle)
	local logData = { }
	
	logData.event = "LoreBook"
	logData.bookTitle = bookTitle
	logData.known = true
	
	uespLog.AppendDataToLog("all", logData, uespLog.GetPlayerPositionData(), uespLog.GetTimeData())
	 
	uespLog.MsgType(uespLog.MSG_OTHER, "UESP: Lore book "..bookTitle.." (already known)")
end


function uespLog.OnLoreBookLearned (eventCode, categoryIndex, collectionIndex, bookIndex, guildIndex)
	local logData = { }
    local bookTitle, icon, known = GetLoreBookInfo(categoryIndex, collectionIndex, bookIndex)
	local collectName = GetLoreCollectionInfo(categoryIndex, collectionIndex)
	local cateName = GetLoreCategoryInfo(logData.categoryIndex)

	logData.event = "LoreBook"
	logData.bookTitle = bookTitle	
	logData.icon = icon
	logData.category = categoryIndex
	logData.collection = collectionIndex
	logData.index = bookIndex
	logData.guild = guildIndex
	logData.known = known
	
	uespLog.AppendDataToLog("all", logData, uespLog.GetPlayerPositionData(), uespLog.GetTimeData())
		 
	uespLog.MsgType(uespLog.MSG_OTHER, "UESP: Lore book "..bookTitle.." (guild "..tostring(guildIndex)..", "..tostring(cateName)..":"..tostring(collectName)..")")
	
	uespLog.LastLoreBookTitle = bookTitle
	uespLog.LastLoreBookTime = GetGameTimeMilliseconds()
end


function uespLog.OnSkillRankUpdate (eventCode, skillType, skillIndex, rank)
	local logData = { }
	local name, rank1, discovered = GetSkillLineInfo(skillType, skillIndex)
	
	if (not discovered and skillType == SKILL_TYPE_RACIAL) then
		return
	end

	logData.event = "SkillRankUpdate"
	logData.skillType = skillType	
	logData.skillIndex = skillIndex
	logData.rank = rank
	logData.name = name
	
	uespLog.AppendDataToLog("all", logData, uespLog.GetPlayerPositionData(), uespLog.GetTimeData())
		 
	uespLog.MsgType(uespLog.MSG_OTHER, ""..tostring(name).." skill line raised to rank "..tostring(rank).."!")
end


function uespLog.OnBuyReceipt (eventCode, itemLink, entryType, entryQuantity, money, specialCurrencyType1, specialCurrencyInfo1, specialCurrencyQuantity1, specialCurrencyType2, specialCurrencyInfo2, specialCurrencyQuantity2, itemSoundCategory)
	local logData = { }
	local itemText, itemColor, itemData, niceName, niceLink = uespLog.ParseLink(itemLink)
	local currency = GetCurrencyName(CURT_MONEY, false, true)
	local amount = money
	
	logData.event = "Buy"
	logData.itemLink = itemLink
	logData.entryType = entryType
	logData.value = money
	logData.qnt = entryQuantity
	logData.sound = itemSoundCategory
	
	if (specialCurrencyQuantity1 > 0) then 
		logData.currency1 = specialCurrencyInfo1
		logData.type1 = specialCurrencyType1
		logData.currencyQnt1 = specialCurrencyQuantity1
		amount = specialCurrencyQuantity1
		currency = GetCurrencyName(specialCurrencyType1, false, true)
	end
	
	if (specialCurrencyQuantity2 > 0) then 
		logData.currency2 = specialCurrencyInfo2
		logData.type2 = specialCurrencyType2
		logData.currencyQnt2 = specialCurrencyQuantity2
		amount = specialCurrencyQuantity2
		currency = GetCurrencyName(specialCurrencyType2, false, true)
	end
	
	uespLog.AppendDataToLog("all", logData, uespLog.GetPlayerPositionData(), uespLog.GetTimeData())
	 
	uespLog.MsgColorType(uespLog.MSG_LOOT, uespLog.itemColor, "Bought "..niceLink.." for "..tostring(amount).." "..tostring(currency))
	uespLog.TrackLoot(itemLink, entryQuantity, "bought")
end


function uespLog.OnSellReceipt (eventCode, itemLink, itemQuantity, money)
	local logData = { }
	local itemText, itemColor, itemData, niceName, niceLink = uespLog.ParseLink(itemLink)
	
	logData.event = "Sell"
	logData.itemLink = itemLink
	logData.qnt = itemQuantity
	logData.value = money

	uespLog.AppendDataToLog("all", logData, uespLog.GetPlayerPositionData(), uespLog.GetTimeData())
	 
	if (itemQuantity == 1) then
		uespLog.MsgColorType(uespLog.MSG_LOOT, uespLog.itemColor, "Sold "..niceLink.." for "..tostring(money).." gold")
	else
		uespLog.MsgColorType(uespLog.MSG_LOOT, uespLog.itemColor, "Sold "..niceLink.." (x"..tostring(itemQuantity)..") for "..tostring(money).." gold")
	end
	
	uespLog.TrackLoot("gold", money, "sold")
end


function uespLog.GetQuestUniqueDataId(journalIndex, questName, poiIndex)

	if (questName == nil or poiIndex == nil) then
		local _
		questName = GetJournalQuestInfo(journalIndex)
		_, _, _, poiIndex = GetJournalQuestLocationInfo(journalIndex)
	end
		
	if (questName == "A Bitter Pill") then
		if (poiIndex <= 100) then
			return questName .. "1"
		else
			return questName .. "2"
		end
	end
		
	if (questName == nil or questName == "") then
		return "nil"
	end
	
	return questName
end


function uespLog.OnQuestAdded (eventCode, journalIndex, questName, objectiveName)
	local logData = { }
	local questStageData = uespLog.GetCharQuestStageData()
	local questUniqueIds = uespLog.GetCharQuestUniqueIds()
	local questDataId = uespLog.GetQuestUniqueDataId(journalIndex)
	
	questStageData[questDataId] = 1
	questUniqueIds[questDataId] = GetGameTimeMilliseconds()
	
	--logData.event = "QuestAdded"
	--logData.quest = questName
	--logData.objective = objectiveName
	--logData.stepIndex, logData.condIndex = uespLog.FindQuestCurrentStage(journalIndex, objectiveName)
	--uespLog.AppendDataToLog("all", logData, uespLog.GetPlayerPositionData(), uespLog.GetTimeData())
		
	uespLog.LogQuestData(journalIndex)
	
	if (objectiveName ~= "") then
		uespLog.MsgType(uespLog.MSG_QUEST, "Quest "..tostring(questName)..", "..tostring(objectiveName).." added!")
	else
		uespLog.MsgType(uespLog.MSG_QUEST, "Quest "..tostring(questName).." added!")
	end
	
	--uespLog.DebugMsg("Quest Step/Condition Index ("..tostring(journalIndex)..") :"..tostring(logData.stepIndex) .. ":"..tostring(logData.condIndex))
	--uespLog.CheckQuestItems(journalIndex, questName)
	
	uespLog.DailyQuestOnQuestStart(questName, journalIndex)
end


function uespLog.LogQuestData (journalIndex)
	local logData = { }
	local numSteps = GetJournalQuestNumSteps(journalIndex)
	local questName = GetJournalQuestName(journalIndex)
	local questDataId = uespLog.GetQuestUniqueDataId(journalIndex)
	local questStageIndex = uespLog.GetCharQuestStageData()[questDataId] or nil
	local questUniqueId = uespLog.GetCharQuestUniqueIds()[questDataId] or 0
	
	logData.event = "Quest::Start"
	logData.level = GetJournalQuestLevel(journalIndex)
	logData.type = GetJournalQuestType(journalIndex)
	logData.repeatType = GetJournalQuestRepeatType(journalIndex)
	logData.displayType = GetJournalQuestInstanceDisplayType(journalIndex)
	logData.quest, logData.bgText = GetJournalQuestInfo(journalIndex)
	logData.jourIndex = journalIndex
	logData.questZone, logData.objective, logData.zoneIndex, logData.poiIndex = GetJournalQuestLocationInfo(journalIndex)
	
	--logData.goal, logData.endDialog, logData.confirm, logData.decline, logData.endBgText, logData.endJournalText = GetJournalQuestEnding(journalIndex)
	
	logData.shareable = GetIsQuestSharable(journalIndex)
	logData.numTools = GetQuestToolCount(journalIndex)
	logData.timerStart, logData.timerEnd, logData.timerVisible = GetJournalQuestTimerInfo(journalIndex)
	logData.timerCaption = GetJournalQuestTimerCaption(journalIndex)
	logData.numSteps = numSteps
	logData.startZoneIndex = GetJournalQuestStartingZone(journalIndex)
	logData.stageIndex = questStageIndex
	logData.uniqueId = questUniqueId 
	
	uespLog.AppendDataToLog("all", logData, uespLog.GetPlayerPositionData(), uespLog.GetTimeData())
	
	uespLog.LogQuestStepData(journalIndex)
end


function uespLog.LogQuestRewardData (journalIndex)
	local questName = GetJournalQuestName(journalIndex)
	local numRewards = GetJournalQuestNumRewards(journalIndex)
	local questDataId = uespLog.GetQuestUniqueDataId(journalIndex)
	local questUniqueId = uespLog.GetCharQuestUniqueIds()[questDataId] or 0
	local logData = { }
	
	for rewardIndex = 1, numRewards do
		logData = {}
		logData.event = "Quest::Reward"
		
		logData.quest = questName
		logData.type, logData.name, logData.count, logData.icon, logData.usage, logData.quality, logData.itemType = GetJournalQuestRewardInfo(journalIndex, rewardIndex)
		logData.itemId = GetJournalQuestRewardItemId(journalIndex, rewardIndex)
		logData.collectId = GetJournalQuestRewardCollectibleId(journalIndex, rewardIndex)
		logData.uniqueId = questUniqueId

		uespLog.AppendDataToLog("all", logData, uespLog.GetTimeData())
		
		if (logData.type == REWARD_TYPE_MONEY) then
			uespLog.LogQuestGoldReward(questName, logData.count, questUniqueId)
		end
	end
end


function uespLog.LogQuestGoldReward(questName, goldReward, uniqueId)
	local logData = {}
	
	logData.event = "QuestGoldReward"
	logData.gold = goldReward
	logData.quest = questName
	logData.level = GetUnitLevel("player")
	logData.effLevel = GetUnitEffectiveLevel("player")
	logData.esoPlus = IsESOPlusSubscriber()
	logData.uniqueId = uniqueId
	
	uespLog.AppendDataToLog("all", logData, uespLog.GetTimeData())
end


function uespLog.LogQuestExperienceReward(questName, xpReward, uniqueId)
	local logData = {}
	
	if (xpReward <= 0) then
		return
	end
	
	logData.event = "QuestXPReward"
	logData.xp = xpReward
	logData.quest = questName
	logData.uniqueId = uniqueId
	logData.level = GetUnitLevel("player")
	logData.effLevel = GetUnitEffectiveLevel("player")
	logData.esoPlus = IsESOPlusSubscriber()
	
	uespLog.AppendDataToLog("all", logData, uespLog.GetTimeData())
end


function uespLog.LogQuestStepData (journalIndex)
	local numSteps = GetJournalQuestNumSteps(journalIndex)
	local questName = GetJournalQuestName(journalIndex)
	local questDataId = uespLog.GetQuestUniqueDataId(journalIndex)
	local questStageIndex = uespLog.GetCharQuestStageData()[questDataId] or nil
	local questUniqueId = uespLog.GetCharQuestUniqueIds()[questDataId] or 0
	local logData = {}

	for stepIndex = 1, numSteps do
		logData = {}
		logData.event = "Quest::Step"
		logData.quest = questName
		logData.step = stepIndex
		logData.stageIndex = questStageIndex
		logData.uniqueId = questUniqueId
		logData.text, logData.visible, logData.stepType, logData.overrideText, logData.numCond = GetJournalQuestStepInfo(journalIndex, stepIndex)
		
		if (logData.visible == nil) then
			logData.visible = -1
		end
		
		uespLog.AppendDataToLog("all", logData, uespLog.GetPlayerPositionData(), uespLog.GetTimeData())
		
		local numConditions = logData.numCond
		
		for conditionIndex = 1, numConditions do
			logData = {}
			logData.event = "Quest::Condition"
			logData.quest = questName
			logData.step = stepIndex
			logData.stageIndex = questStageIndex
			logData.uniqueId = questUniqueId
			logData.condition = conditionIndex
			logData.condType = GetJournalQuestConditionType(journalIndex, stepIndex, conditionIndex, TRACKING_LEVEL_ASSISTED)
			logData.condType2 = GetJournalQuestConditionType(journalIndex, stepIndex, conditionIndex, TRACKING_LEVEL_TRACKED)
			logData.condType3 = GetJournalQuestConditionType(journalIndex, stepIndex, conditionIndex, TRACKING_LEVEL_UNTRACKED)
			logData.text, _, logData.maxValue, logData.isFail, logData.isComplete, logData.isShared, logData.isVisible = GetJournalQuestConditionInfo(journalIndex, stepIndex, conditionIndex)
			
			uespLog.AppendDataToLog("all", logData)
			
			local itemLink = GetQuestItemLink(journalIndex, stepIndex, conditionIndex)
			
			if (itemLink ~= "") then
				uespLog.LogQuestItemLink(journalIndex, stepIndex, conditionIndex, questName)
			end
		end
	end
	
	local numTools = GetQuestToolCount(journalIndex)
	
	for toolIndex = 1, numTools do
		uespLog.LogQuestToolItemLink(journalIndex, toolIndex, questName)
	end
	
end

uespLog.lastQuestRemovedJournalIndex = -1
uespLog.lastQuestRemovedDataId = -1


function uespLog.OnQuestRemoved (eventCode, isCompleted, journalIndex, questName, zoneIndex, poiIndex, questId)
	local logData = { }
	local questStageData = uespLog.GetCharQuestStageData()
	local questUniqueIds = uespLog.GetCharQuestUniqueIds()
	local questDataId = uespLog.GetQuestUniqueDataId(journalIndex, questName, poiIndex)
	
	uespLog.lastQuestRemovedJournalIndex = journalIndex
	uespLog.lastQuestRemovedDataId = questDataId
		
	logData.event = "QuestRemoved"
	logData.quest = questName
	logData.completed = isCompleted
	logData.zoneIndex = zoneIndex
	logData.poiIndex = poiIndex
	logData.questId = questId
	logData.journalIndex = journalIndex
	logData.stageIndex = questStageData[questDataId] or nil
	logData.uniqueId = questUniqueIds[questDataId] or 0
		
	uespLog.AppendDataToLog("all", logData, uespLog.GetPlayerPositionData(), uespLog.GetTimeData())

	uespLog.MsgType(uespLog.MSG_QUEST, "Quest "..tostring(questName).." removed!")
	
	uespLog.DailyQuestOnQuestComplete(questName, journalIndex, isCompleted)
	
		-- Reset saved data in a bit so other events yet to be called can use it
	zo_callLater(function() 
		uespLog.ResetSavedQuestData(questDataId) 
	end, 2000)
end


function uespLog.ResetSavedQuestData(questDataId)
	local questStageData = uespLog.GetCharQuestStageData()
	local questUniqueIds = uespLog.GetCharQuestUniqueIds()
	
	questStageData[questDataId] = nil
	questUniqueIds[questDataId] = nil
end


function uespLog.OnQuestComplete(eventCode, questName, level, previousExperience, currentExperience, championPoints, questType, instanceDisplayType)
	local logData = { }
	local journalIndex = uespLog.lastQuestRemovedJournalIndex
	local questDataId = uespLog.lastQuestRemovedDataId
	local questUniqueId = uespLog.GetCharQuestUniqueIds()[questDataId] or 0
	
	logData.event = "QuestComplete"
	logData.quest = questName
	logData.level = level
	logData.cp = championPoints
	logData.questType = questType
	logData.displayType = instanceDisplayType
	logData.xp = currentExperience - previousExperience
	logData.uniqueId = questUniqueId
	logData.journalIndex = journalIndex
		
	uespLog.AppendDataToLog("all", logData, uespLog.GetPlayerPositionData(), uespLog.GetTimeData())
	
	uespLog.LogQuestExperienceReward(questName, logData.xp, questUniqueId)
	
	uespLog.lastQuestRemovedJournalIndex = -1
	uespLog.lastQuestRemovedDataId = -1
	--uespLog.DebugExtraMsg("Quest "..tostring(questName).." Complete: "..tostring(logData.xp).." XP")
end


function uespLog.OnQuestObjectiveCompleted (eventCode, zoneIndex, poiIndex, xpGained)
	local logData = { }
	
	logData.event = "QuestObjComplete"
	logData.xpGained = xpGained
	logData.zoneIndex = zoneIndex
	logData.poiIndex = poiIndex
	
	uespLog.AppendDataToLog("all", logData, uespLog.GetPlayerPositionData(), uespLog.GetTimeData())
	
	uespLog.DebugMsg("UESP: Quest objective completed!")
end


function uespLog.OnQuestCounterChanged (eventCode, journalIndex, questName, conditionText, conditionType, currConditionVal, newConditionVal, conditionMax, isFailCondition, stepOverrideText, isPushed, isComplete, isConditionComplete, isStepHidden)
	local logData = { }
	
	logData.event = "QuestChanged"
	logData.quest = questName
	logData.condition = conditionText
	logData.condType = conditionType
	logData.condVal = newConditionVal
	logData.condMaxVal = conditionMax
	logData.isFail = isFailCondition
	logData.isPushed = isPushed
	logData.isComplete = isComplete
	logData.isCondComplete = isConditionComplete
	logData.isHidden = isStepHidden
	if (stepOverrideText ~= "") then logData.overrideText = stepOverrideText end
	
	--logData.stepIndex, logData.condIndex = uespLog.FindQuestCurrentStage(journalIndex, conditionText, conditionType, newConditionVal, conditionMax)
	
	--uespLog.AppendDataToLog("all", logData, uespLog.GetPlayerPositionData(), uespLog.GetTimeData())
	
	if (newConditionVal ~= currConditionVal and not isStepHidden) then
		uespLog.MsgType(uespLog.MSG_QUEST, "Quest "..questName..", "..conditionText.." now "..tostring(newConditionVal).."/"..tostring(conditionMax)..".")
	end
	
	--uespLog.DebugMsg("Quest Step/Condition Index ("..tostring(journalIndex)..") :"..tostring(logData.stepIndex) .. ":"..tostring(logData.condIndex))
end


function uespLog.FindQuestCurrentStage(journalIndex, activeConditionText, activeConditionType, activeConditionValue, activeConditionMax)
	local numSteps = GetJournalQuestNumSteps(journalIndex)
	local questName, backgroundText, activeStepText, activeStepType, activeStepTrackerOverrideText = GetJournalQuestInfo(journalQuestIndex)
	
	for stepIndex = 1, numSteps do
		local stepText, visible, stepType, trakerOverride, numConditions = GetJournalQuestStepInfo(journalQuestIndex, stepIndex)	
		
		if (stepText == activeStepText and stepType == activeStepType) then
			resultStepIndex = stepIndex 
			
			if (conditionText ~= nil) then 
			
				if (numConditions <= 0) then
					return stepIndex, 0
				end
			
				if (numConditions == 1) then
					return stepIndex, 1 
				end
			
				for conditionIndex = 1, numConditions do
					local conditionText, currentValue, maxValue = GetJournalQuestConditionInfo(journalQuestIndex, stepIndex, conditionIndex)
					local conditionType = GetJournalQuestConditionType(journalQuestIndex, stepIndex, conditionIndex)
					
					if (conditionText == activeConditionText and (activeConditionMax == nil or activeConditionMax == maxValue) and (conditionType == nil or conditionType == activeConditionType)) then
						return stepIndex, conditionIndex
					end
				end
			end
			
			return stepIndex, nil
		end
	
	end
	
	return nil, nil
end


function uespLog.OnQuestCompleteExperience (eventCode, questName, xpGained)
	local logData = { }
	
	logData.event = "QuestCompleteExperience"
	logData.quest = questName
	logData.xpGained = xpGained
	
	uespLog.AppendDataToLog("all", logData, uespLog.GetPlayerPositionData(), uespLog.GetTimeData())
	 
	uespLog.MsgType(uespLog.MSG_QUEST, "Finished quest "..tostring(questName).."! "..tostring(xpGained).." xp gained.")
end


uespLog.EQUIPTYPES = {
	[0]  = "Invalid",
	[1]  = "Head",
	[2]  = "Neck",
	[3]  = "Chest",
	[4]  = "Shoulders",
	[5]  = "One Hand",
	[6]  = "Two Hand",
	[7]  = "Off Hand",
	[8]  = "Waist",
	[9]  = "Legs",
	[10] = "Feet",
	[11] = "Costume",
	[12] = "Ring",
	[13] = "Hand",
	[14] = "Main Hand",
}


function uespLog.GetItemEquipTypeStr(equipType)

	if (uespLog.EQUIPTYPES[equipType] ~= nil) then
		return uespLog.EQUIPTYPES[equipType]
	end
	
	return "Unknown ("..tostring(equipType)..")"
end


uespLog.old_XPREASONS = {
	[-1] = "none",
	[0] = "kill",
	[1] = "quest",
	[2] = "complete poi",
	[3] = "discover poi",
	[4] = "command",
	[5] = "keep reward",
	[6] = "battleground",
	[7] = "scripted event", 
	[8] = "medal",
	[9] = "finesse",
	[10] = "lockpick",
	[11] = "collect book",
	[12] = "skill book",
	[13] = "action",
	[14] = "guild rep",
	[15] = "AVA",
	[16] = "tradeskill",
	[17] = "reward",
	[18] = "tradeskill achievement",
	[19] = "tradeskill quest",
	[20] = "tradeskill consume", 
	[21] = "tradeskill harvest",
	[22] = "tradeskill recipe",
	[23] = "tradeskill trait",
	[24] = "boss kill",
}

uespLog.XPREASONS = {
	[-1] = "none",
	[PROGRESS_REASON_ACHIEVEMENT] = "achievement", -- 25
	[PROGRESS_REASON_ACTION] = "action",
	[PROGRESS_REASON_ALLIANCE_POINTS] = "alliance points",
	[PROGRESS_REASON_AVA] = "AVA",
	[PROGRESS_REASON_BATTLEGROUND] = "battleground",
	[PROGRESS_REASON_BOOK_COLLECTION_COMPLETE] = "book collection complete",
	[PROGRESS_REASON_BOSS_KILL] = "boss kill",
	[PROGRESS_REASON_COLLECT_BOOK] = "collect book",
	[PROGRESS_REASON_COMMAND] = "command",
	[PROGRESS_REASON_COMPLETE_POI] = "complete POI",
	[PROGRESS_REASON_DARK_ANCHOR_CLOSED] = "dark anchor closed",
	[PROGRESS_REASON_DARK_FISSURE_CLOSED] = "dark fissure closed",
	[PROGRESS_REASON_DISCOVER_POI] = "discover POI",
	[PROGRESS_REASON_DUNGEON_CHALLENGE] = "unknown challenge",
	[PROGRESS_REASON_EVENT] = "event",
	[PROGRESS_REASON_FINESSE] = "finesse",
	[PROGRESS_REASON_GRANT_REPUTATION] = "grant reputation",
	[PROGRESS_REASON_GUILD_REP] = "guild rep",
	[PROGRESS_REASON_JUSTICE_SKILL_EVENT] = "justice skill event",
	[PROGRESS_REASON_KEEP_REWARD] = "keep reward",
	[PROGRESS_REASON_KILL] = "kill",
	[PROGRESS_REASON_LFG_REWARD] = "LFG reward",
	[PROGRESS_REASON_LOCK_PICK] = "lockpick",
	[PROGRESS_REASON_MEDAL] = "medal",
	--[PROGRESS_REASON_NONE] = "none",
	[PROGRESS_REASON_OTHER] = "other",
	[PROGRESS_REASON_OVERLAND_BOSS_KILL] = "boss kill",
	[PROGRESS_REASON_PVP_EMPEROR] = "PVP emperor",
	[PROGRESS_REASON_QUEST] = "quest",
	[PROGRESS_REASON_REWARD] = "reward",
	[PROGRESS_REASON_SCRIPTED_EVENT] = "scripted event",
	[PROGRESS_REASON_SKILL_BOOK] = "skill book",
	[PROGRESS_REASON_TRADESKILL] = "tradeskill",
	[PROGRESS_REASON_TRADESKILL_ACHIEVEMENT] = "tradeskill achievement",
	[PROGRESS_REASON_TRADESKILL_CONSUME] = "tradeskill consume",
	[PROGRESS_REASON_TRADESKILL_HARVEST] = "harvest",
	[PROGRESS_REASON_TRADESKILL_QUEST] = "tradeskill quest",
	[PROGRESS_REASON_TRADESKILL_RECIPE] = "recipe",
	[PROGRESS_REASON_TRADESKILL_TRAIT] = "tradeskill trait",
}


function uespLog.GetXPReasonStr(reason)

	if (uespLog.XPREASONS[reason] ~= nil) then
		return uespLog.XPREASONS[reason]
	end
	
	return "unknown ("..tostring(reason)..")"
end


function uespLog.OnExperienceGain (eventCode, reason, level, previousExperience, currentExperience)
	local logData = { }
	local reasonStr = uespLog.GetXPReasonStr(reason)
	
	logData.event = "ExperienceUpdate"
	logData.unit = "player"
	logData.xpGained = currentExperience - previousExperience
	logData.level = level
	logData.reason = reason
	
	uespLog.currentXp = currentExperience
	
	if (logData.xpGained == 0) then
		return
	elseif (reason == -1) then
		uespLog.MsgColorType(uespLog.MSG_XP, uespLog.xpColor, "You gained "..tostring(logData.xpGained).." xp for unknown reason.")
		uespLog.TrackLoot("xp", logData.xpGained, "unknown")
		return
	end
	
	uespLog.AppendDataToLog("all", logData, uespLog.GetPlayerPositionData(), uespLog.GetTimeData())
	 
	uespLog.MsgColorType(uespLog.MSG_XP, uespLog.xpColor, "You gained "..tostring(logData.xpGained).." xp for "..reasonStr..".")
	uespLog.TrackLoot("xp", logData.xpGained, reasonStr)
end


function uespLog.OnExperienceUpdate (eventCode, unitTag, currentExp, maxExp, reason)
	local logData = { }
	local reasonStr = uespLog.GetXPReasonStr(reason)
	
	logData.event = "ExperienceUpdate"
	logData.unit = unitTag
	logData.xpGained = currentExp - uespLog.currentXp
	logData.maxXP = maxExp
	logData.reason = reason
	
	uespLog.currentXp = currentExp
	
	if (logData.xpGained == 0) then
		return
	elseif (reason == -1) then
		uespLog.MsgColorType(uespLog.MSG_XP, uespLog.xpColor, "You gained "..tostring(logData.xpGained).." xp for unknown reason.")
		uespLog.TrackLoot("xp", logData.xpGained, "unknown")
		return
	end
	
	uespLog.AppendDataToLog("all", logData, uespLog.GetPlayerPositionData(), uespLog.GetTimeData())
	 
	if (unitTag == "player") then
		uespLog.MsgColorType(uespLog.MSG_XP, uespLog.xpColor, "You gained "..tostring(logData.xpGained).." xp for "..uespLog.GetXPReasonStr(reason)..".")
		uespLog.TrackLoot("xp", logData.xpGained, reasonStr)
	end
	
end


function uespLog.OnAlliancePointsUpdate (eventCode, alliancePoints, playSound, difference)
	local logData = { }
	
	logData.event = "AllianceXPUpdate"
	logData.xpGained = difference
	logData.maxXP = alliancePoints
	
	if (logData.difference == 0) then
		return
	end
	
	uespLog.AppendDataToLog("all", logData, uespLog.GetPlayerPositionData(), uespLog.GetTimeData())
	 
	uespLog.MsgColorType(uespLog.MSG_XP, uespLog.xpColor, "You gained "..tostring(logData.xpGained).." alliance points.")
	uespLog.TrackLoot("ap", logData.xpGained, "unknown")
end

 
function uespLog.OnSkillPointsChanged (eventCode, pointsBefore, pointsNow, partialPointsBefore, partialPointsNow, reason)
	local isSkyshard = false
	local logData = { }
	
	if (partialPointsBefore ~= partialPointsNow) then
		isSkyshard = true
	end
	
	--uespLog.DebugMsg("OnSkillPointsChanged:"..tostring(pointsBefore)..", "..tostring(pointsNow)..", "..tostring(partialPointsBefore)..", "..tostring(partialPointsNow)..", "..tostring(isSkyshard))
	
	logData.event = "SkillPointsChanged"
	logData.points = pointsNow - pointsBefore
	logData.pointsBefore = pointsBefore
	logData.pointsNow = pointsNow
	logData.partialPointsBefore = partialPointsBefore
	logData.partialPointsNow = partialPointsNow
	logData.reason = reason
		
	uespLog.AppendDataToLog("all", logData, uespLog.GetPlayerPositionData(), uespLog.GetTimeData())
	 
	if (pointsBefore > pointsNow) then
		local points = -logData.points
		uespLog.MsgType(uespLog.MSG_OTHER, "You lost ".. tostring(points) .." skill points!")
	elseif (isSkyshard and pointsBefore == pointsNow) then
		uespLog.MsgType(uespLog.MSG_OTHER, "You found a Skyshard ("..GetNumSkyShards().."/3 pieces)!")
	elseif (isSkyshard and logData.points == 1) then
		uespLog.MsgType(uespLog.MSG_OTHER, "You found a Skyshard...gained ".. tostring(logData.points) .." skill point!")
	elseif (logData.points == 1) then
		uespLog.MsgType(uespLog.MSG_OTHER, "You gained ".. tostring(logData.points) .." skill point!")
	else
		--local points = partialPointsNow  - partialPointsBefore
		uespLog.MsgType(uespLog.MSG_OTHER, "You gained ".. tostring(logData.points) .." skill points!")
	end
	
end


function uespLog.OnQuestOptionalStepAdvanced (eventCode, text)

	if (text == "") then
		return
	end
	
	local logData = { }
	
	logData.event = "QuestOptionalStep"
	logData.text = text
	
	uespLog.AppendDataToLog("all", logData, uespLog.GetPlayerPositionData(), uespLog.GetTimeData())
	 
	uespLog.MsgType(uespLog.MSG_QUEST, "Quest optional step advanced ("..text..")")
end


function uespLog.OnQuestAdvanced (eventCode, journalIndex, questName, isPushed, isComplete, mainStepChanged)
	local logData = { }
	local questDataId = uespLog.GetQuestUniqueDataId(journalIndex)
	local questStageData = uespLog.GetCharQuestStageData()
	local questUniqueId = uespLog.GetCharQuestUniqueIds()[questDataId] or 0
	
	if (questStageData[questDataId] ~= nil) then
		questStageData[questDataId] = questStageData[questDataId] + 1
	end	
	
	logData.event = "QuestAdvanced"
	logData.quest = questName
	logData.isPushed = isPushed
	logData.isComplete = isComplete
	logData.mainStepChanged = mainStepChanged
	logData.stageIndex = questStageData[questDataId]
	logData.uniqueId = questUniqueId
	logData.stepIndex, logData.condIndex = uespLog.FindQuestCurrentStage(journalIndex)
	
	if (isComplete) then
		logData.goal, logData.endDialog, logData.confirm, logData.decline, logData.endBgText, logData.endJournalText = GetJournalQuestEnding(journalIndex)
		uespLog.LogQuestRewardData(journalIndex)
	end

	uespLog.AppendDataToLog("all", logData, uespLog.GetPlayerPositionData(), uespLog.GetTimeData())
	 
	if (logData.stageIndex == nil) then
		uespLog.DebugMsg("UESP: Quest "..questName.." advanced a stage...")
	else
		uespLog.DebugMsg("UESP: Quest "..questName.." advanced to stage "..tostring(logData.stageIndex).."...")
	end
	
	uespLog.LogQuestStepData(journalIndex)
	
	--uespLog.CheckQuestItems(journalIndex, questName)
end


function uespLog.OnRecipeLearned (eventCode, recipeListIndex, recipeIndex)
	uespLog.DumpRecipe(recipeListIndex, recipeIndex,  uespLog.GetTimeData())
	
	local known, recipeName = GetRecipeInfo(recipeListIndex, recipeIndex)
	uespLog.MsgType(uespLog.MSG_OTHER, "You learned a new recipe " ..tostring(recipeName).."!")
end


function uespLog.OnCurrencyUpdate (eventCode, currency, currencyLocation, newValue, oldValue, reason)
	local diff = newValue - oldValue
	
	--uespLog.DebugMsg("Currency Update: "..tostring(currency)..", "..tostring(currencyLocation)..", "..tostring(newValue).." to "..tostring(oldValue).." ("..tostring(diff).."), "..tostring(reason))
	
	if (reason == CURRENCY_CHANGE_REASON_PLAYER_INIT) then
		return
	end

	if (CURT_CHAOTIC_CREATIA ~= nil and currency == CURT_CHAOTIC_CREATIA) then
	
		if (diff < 0 and reason ~= CURRENCY_CHANGE_REASON_VENDOR) then
			uespLog.MsgColorType(uespLog.MSG_OTHER, uespLog.itemColor, "You lost "..tostring(-diff).." transmute stones.")
		elseif (diff > 0) then
			uespLog.MsgColorType(uespLog.MSG_OTHER, uespLog.itemColor, "You received "..tostring(diff).." transmute stones.")
			uespLog.TrackLoot("transmute stone", diff, "loot")
		end
		
	elseif (currency == CURT_WRIT_VOUCHERS) then
	
		if (diff < 0) then
		    -- This is 
			--uespLog.MsgColorType(uespLog.MSG_OTHER, uespLog.itemColor, "You lost "..tostring(-diff).." writ vouchers.")
		elseif (diff > 0) then
			uespLog.MsgColorType(uespLog.MSG_OTHER, uespLog.itemColor, "You received "..tostring(diff).." writ vouchers.")
			uespLog.TrackLoot("writ voucher", diff, "loot")
		end
	
	end
end


function uespLog.OnTelvarStoneUpdate (eventCode, newStones, oldStones, reason)
	local msg = "gained"
	local logData = { }
	local posData = uespLog.GetLastTargetData()
	
	if (reason == CURRENCY_CHANGE_REASON_PLAYER_INIT) then
		return
	end
	
	if (posData.x == nil or posData.x == "") then
		posData = uespLog.GetPlayerPositionData()
	end
	
	logData.event = "TelvarUpdate"
	logData.qnt = newStones - oldStones
	logData.reason = reason
			
	uespLog.AppendDataToLog("all", logData, posData, uespLog.GetTimeData())
	
	if (logData.qnt == 0) then
		return
	elseif (logData.qnt < 0) then
		logData.qnt = -1*logData.qnt
		msg = "lost"
	end
	
	if (reason ~= 35) then
		uespLog.MsgColorType(uespLog.MSG_LOOT, uespLog.itemColor, "You "..msg.." "..tostring(logData.qnt).." telvar stones ("..tostring(newStones).." total)")
	end
	
	if (logData.qnt > 0) then
		uespLog.TrackLoot("telvar", logData.qnt, "loot")
	end
end


function uespLog.OnMoneyUpdate (eventCode, newMoney, oldMoney, reason)
	local logData = { }
	local posData = uespLog.GetLastTargetData()
	local lootMsg = ""
	
	if (reason == CURRENCY_CHANGE_REASON_PLAYER_INIT) then
		return
	end
	
	if (posData.x == nil or posData.x == "") then
		posData = uespLog.GetPlayerPositionData()
	end
	
	uespLog.lastMoneyChange = newMoney - oldMoney
	uespLog.lastMoneyGameTime = GetGameTimeMilliseconds()
	
	if (posData.lastTarget ~= nil) then
		lootMsg = " from "..tostring(posData.lastTarget)
	end
	
	logData.reason = reason

		-- 0 = loot, 13 = loot?
	if (reason == 0 or reason == 13) then
		logData.event = "MoneyGained"
		logData.qnt = uespLog.lastMoneyChange
			
		uespLog.AppendDataToLog("all", logData, posData, uespLog.GetTimeData())
		uespLog.MsgColorType(uespLog.MSG_LOOT, uespLog.itemColor, "You looted "..tostring(uespLog.lastMoneyChange).." gold"..lootMsg..".")
		
		uespLog.TrackLoot("gold", uespLog.lastMoneyChange, posData.lastTarget)
		
		-- 4 = quest reward
	elseif (reason == 4) then
		logData.event = "QuestMoney"
		logData.qnt = uespLog.lastMoneyChange

		uespLog.AppendDataToLog("all", logData, posData, uespLog.GetTimeData())
		uespLog.MsgColorType(uespLog.MSG_OTHER, uespLog.itemColor, "Quest reward "..tostring(uespLog.lastMoneyChange).." gold"..lootMsg..".")
		
		uespLog.TrackLoot("gold", uespLog.lastMoneyChange, "quest")
		
		-- 62 = Stolen
	elseif (reason == 62) then
		logData.event = "Stolen"
		logData.qnt = uespLog.lastMoneyChange

		uespLog.AppendDataToLog("all", logData, posData, uespLog.GetTimeData())
		uespLog.MsgColorType(uespLog.MSG_OTHER, uespLog.itemColor, "You stole "..tostring(uespLog.lastMoneyChange).." gold"..lootMsg..".")
		
		uespLog.TrackLoot("gold", uespLog.lastMoneyChange, posData.lastTarget)
		
		-- Antiquity
	elseif (reason == 11 and uespLog.isDiggingAntiquity) then
		logData.event = "Antiquity"
		logData.qnt = uespLog.lastMoneyChange

		uespLog.AppendDataToLog("all", logData, posData, uespLog.GetTimeData())
		uespLog.MsgColorType(uespLog.MSG_OTHER, uespLog.itemColor, "You looted "..tostring(uespLog.lastMoneyChange).." gold from the dig site.")
		
		uespLog.TrackLoot("gold", uespLog.lastMoneyChange, "Dig Site")
	else
		uespLog.DebugExtraMsg("UESP: Money Change, New="..tostring(newMoney)..",  Old="..tostring(oldMoney)..",  Diff="..tostring(uespLog.lastMoneyChange)..",  Reason="..tostring(reason))
	end	
	
end


-- NOTE: Copied from original API local function in /ingame/zo_loot/loot_shared.lua
function uespLog.UpdateLootWindow(eventCode)
	local name, targetType, actionName, isOwned = GetLootTargetInfo()
	
	--uespLog.DebugMsg("UESP: UpdateLootWindow")
	
	if (name ~= "") then
	
		if targetType == INTERACT_TARGET_TYPE_ITEM then
			name = zo_strformat(SI_TOOLTIP_ITEM_NAME, name)
		elseif targetType == INTERACT_TARGET_TYPE_OBJECT then
			name = zo_strformat(SI_LOOT_OBJECT_NAME, name)
		elseif targetType == INTERACT_TARGET_TYPE_FIXTURE then
			name = zo_strformat(SI_TOOLTIP_FIXTURE_INSTANCE, name)
		end
	end
	
	if (uespLog.GetContainerAutoLoot()) then
		local isAutoloot = GetSetting(SETTING_TYPE_LOOT, LOOT_SETTING_AUTO_LOOT) == "1"
		local isStolenAutoLoot = GetSetting(SETTING_TYPE_LOOT, LOOT_SETTING_AUTO_LOOT_STOLEN) == "1"
		
		if (targetType == INTERACT_TARGET_TYPE_ITEM and ((isOwned and isStolenAutoLoot) or (not isOwned and isAutoloot))) then
			uespLog.lastLootAutoLoot = true
			LOOT_SHARED:LootAllItems()
			--EndInteraction(INTERACTION_LOOT)
			--LootAll(false)
			--LOOT_SHARED:Hide()
			return
		end
	end
	
	--SYSTEMS:GetObject("loot"):UpdateLootWindow(name, actionName, isOwned)
end


function uespLog:LootWindowIsControlHidden()
	local name, targetType, actionName, isOwned = GetLootTargetInfo()
	
	--uespLog.DebugMsg("UESP: LootWindowIsControlHidden")
	
	local isAutoloot = GetSetting(SETTING_TYPE_LOOT, LOOT_SETTING_AUTO_LOOT) == "1"
	local isStolenAutoLoot = GetSetting(SETTING_TYPE_LOOT, LOOT_SETTING_AUTO_LOOT_STOLEN) == "1"
		
	if (uespLog.GetContainerAutoLoot()) then
		if (targetType == INTERACT_TARGET_TYPE_ITEM and ((isOwned and isStolenAutoLoot) or (not isOwned and isAutoloot))) then
			return false
		end	
	end

	return uespLog.Old_LootWindow_IsControlHidden(LOOT_WINDOW.control)
end


function uespLog.OnLootItemFailed(eventCode, reason)

	--uespLog.DebugMsg("UESP: OnLootItemFailed")

	if (reason == LOOT_ITEM_RESULT_INVENTORY_FULL or reason == LOOT_ITEM_RESULT_INVENTORY_FULL_LOOT_ALL) then
	
		if (uespLog.lastLootAutoLoot and not uespLog.lastLootFailed) then
			uespLog.lastLootFailed = true
			--LOOT_SHARED:LootAllItems()
		end
	end
	
end


function uespLog.OnLootUpdated (eventCode)
	
		-- Prevent double messaging/logging
	--if (uespLog.lastTargetData.name == "Remains-Silent") then
		--return
	--end
	
	uespLog.lastLootFailed = false
	uespLog.lastLootAutoLoot = false
	uespLog.lastLootUpdateCount = GetNumLootItems()
	uespLog.lastLootTargetName = uespLog.lastTargetData.name
	uespLog.lastLootLockQuality = nil
	
	local name, targetType, actionName, isOwned = GetLootTargetInfo()
	
	if (name ~= "" and targetType == 2) then
		uespLog.lastActivateInfo.gameTime = 0
		uespLog.lastLootTargetGameTime = GetGameTimeSeconds()
		uespLog.lastLootTargetName1 = name
		uespLog.lastLootTargetType = targetType
		uespLog.lastLootTargetAction = actionName
		uespLog.lastLootTargetIsOwned = isOwned
	end
	
	uespLog.DebugExtraMsg("OnLootUpdated: "..tostring(name)..":"..tostring(targetType)..":"..tostring(actionName))
	
	uespLog.UpdateLootWindow(eventCode)
end


function uespLog.OnTreasureLooted (targetName)
	safeName = string.lower(tostring(targetName))
	local duration = uespLog.GetTreasureTimers()[safeName]

	if (not uespLog.IsTreasureTimerEnabled() or duration == nil or duration <= 0) then
		return
	end
		
	zo_callLater(	function()
						uespLog.MsgColor(uespLog.itemColor, "A "..tostring(targetName).." was looted "..tostring(duration).." sec ago.")
					end, duration*1000)
					
	uespLog.AddTreasureTimer(targetName, duration)
	
	uespLog.DebugMsgColor(uespLog.itemColor, "Created "..tostring(duration).." sec timer for "..tostring(targetName).." just looted.")
end


function uespLog.AddTreasureTimer(targetName, duration)
	local timers = uespLog.savedVars.charInfo.data.treasureTimers
	local timestamp = GetTimeStamp()
	
	if (timers == nil) then
		uespLog.savedVars.charInfo.data.treasureTimers = { }
		timers = uespLog.savedVars.charInfo.data.treasureTimers
	end
		
	timers[#timers + 1] = { ["name"] = targetName, ["duration"] = duration, ["timestamp"] = timestamp, ["endTime"] = timestamp + duration }
	uespLog.CheckTreasureTimers()
end


function uespLog.CheckTreasureTimers()
	local newTimers = {}
	local timers = uespLog.savedVars.charInfo.data.treasureTimers
	local currentTimestamp = GetTimeStamp()
	
	if (timers == nil) then
		uespLog.savedVars.charInfo.data.treasureTimers = { }
		timers = uespLog.savedVars.charInfo.data.treasureTimers
	end
	
	for i, timer in pairs(timers) do
	
		if (timer.endTime > currentTimestamp) then
			newTimers[#newTimers + 1] = timer
		end
		
	end	
	
	uespLog.savedVars.charInfo.data.treasureTimers = newTimers
	return uespLog.savedVars.charInfo.data.treasureTimers
end


function uespLog.OnLootClosed (eventCode)
	
	if (uespLog.lastLootUpdateCount == 0) then
		uespLog.OnTreasureLooted(uespLog.lastLootTargetName)
	elseif (uespLog.lastLootUpdateCount > 0) then
		-- uespLog.DebugMsg("Did not finish looting "..tostring(uespLog.lastLootTargetName))
	else
		-- uespLog.DebugMsg("Unknown "..tostring(uespLog.lastLootUpdateCount).."::"..tostring(uespLog.lastLootTargetName))
	end
	
	uespLog.DebugExtraMsg("OnLootClosed")
	
	uespLog.lastLootUpdateCount = -1
	uespLog.lastLootTargetName = ""
	uespLog.lastLootLockQuality = nil
	uespLog.lastLootTargetGameTime = 0
end


uespLog.lastActivateInfo = {
	name = "",
	gameTime = 0,
}

uespLog.MAX_LASTACTIVATE_TIMEDIFF = 4
uespLog.MAX_LASTLOOT_TIMEDIFF = 2
uespLog.MAX_LASTANTIQUITY_TIMEDIFF = 2


function uespLog.OnClientInteractResult(eventCode, result, targetName)
	local interactType = GetInteractionType()
	
	--uespLog.DebugExtraMsg("OnClientInteractResult: "..tostring(result)..", "..tostring(targetName)..", "..tostring(interactType))
	
	if (targetName == "Dig Site") then
		uespLog.isDiggingAntiquity = true
	end
		
	if (result == 0) then
		uespLog.lastActivateInfo.name = targetName
		uespLog.lastActivateInfo.gameTime = GetGameTimeSeconds()
		uespLog.lastLootTargetGameTime = 0
	end
    
end


function uespLog.OnAntiquityLeadAcquired(eventId, antiquityId)
	local antiquityName = zo_strformat(SI_ANTIQUITY_NAME_FORMATTER, GetAntiquityName(antiquityId))
	local antiquityQuality = GetAntiquityQuality(antiquityId)
	local qualityColorDef = GetAntiquityQualityColor(antiquityQuality)
	local coloredName = qualityColorDef:Colorize(antiquityName)

	if (uespLog.isDiggingAntiquity) then
		uespLog.MsgColorType(uespLog.MSG_LOOT, uespLog.itemColor, "You looted a lead for |r"..coloredName.."|c"..uespLog.itemColor.." from the dig site.")
		uespLog.TrackLoot(antiquityName, 1, "Dig Site")
	else
		-- Handled elsewhere
		uespLog.lastAntiquityIdLeadFound = antiquityId
	end
	
end


function uespLog.OnAntiquityGameOver(eventId, gameOverFlags)

	uespLog.isDiggingAntiquity = false

	if (gameOverFlags ~= ANTIQUITY_DIGGING_GAME_OVER_FLAGS_VICTORY) then
		return
	end
	
	uespLog.lastAntiquityGameOver = GetGameTimeSeconds()
	
	--[[ Functions are not accessible...handled elsewhere for now
	
		-- Antiquity Treasure
	local antiquityId = GetDigSpotAntiquityId()
    local antiquitySetId = GetAntiquitySetId(antiquityId)
	local antiquityName = zo_strformat(SI_ANTIQUITY_NAME_FORMATTER, GetAntiquityName(antiquityId))
    local antiquityQuality = GetAntiquityQuality(antiquityId)
    local qualityColorDef = GetAntiquityQualityColor(antiquityQuality)
	local coloredName = qualityColorDef:Colorize(antiquityName)
	
	uespLog.MsgColorType(uespLog.MSG_LOOT, uespLog.itemColor, "You looted the antiquity |r"..coloredName.."|c"..uespLog.itemColor.." from the dig site.")
	
		-- New Lead
	local newLeadAntiquityId = GetDigSpotNewLeadRewardAntiquityId()
    
    if (newLeadAntiquityId ~= 0) then
        local antiquityLeadName = zo_strformat(SI_ANTIQUITY_LEAD_NAME_FORMATTER, GetAntiquityName(newLeadAntiquityId))
        local antiquityLeadQuality = GetAntiquityQuality(newLeadAntiquityId)
        local antiquityLeadQualityColorDef = GetAntiquityQualityColor(antiquityLeadQuality)
		local coloredLeadName = antiquityLeadQualityColorDef:Colorize(antiquityLeadName)
        		
        uespLog.MsgColorType(uespLog.MSG_LOOT, uespLog.itemColor, "You looted a new lead "..coloredLeadName.." from the dig site.")
    end 
	
	 -- Bonus Rewards
    local numBonusLootRewards = GetNumDigSpotBonusLootRewards()
	
    for i = 1, numBonusLootRewards do
        local lootType, id, name, icon, count, quality = GetDigSpotBonusLootRewardInfo(i)
        local qualityColorDef = nil
        local countText = ""
		
        if lootType == LOOT_TABLE_ENTRY_TYPE_CURRENCY then
            name = zo_strformat(SI_CURRENCY_CUSTOM_TOOLTIP_FORMAT, ZO_Currency_GetAmountLabel(id))
            countText = ZO_CurrencyControl_FormatCurrency(count, true)
			
			uespLog.MsgColorType(uespLog.MSG_LOOT, uespLog.itemColor, "You looted "..count.." gold from the dig site.")
        elseif lootType == LOOT_TABLE_ENTRY_TYPE_ITEM then
            name = zo_strformat(SI_TOOLTIP_ITEM_NAME, name)
            qualityColorDef = GetItemQualityColor(quality)
			name = qualityColorDef:Colorize(name)

            if (count > 1) then
				uespLog.MsgColorType(uespLog.MSG_LOOT, uespLog.itemColor, "You looted "..name.." (x"..tostring(count)..") from the dig site.")
			else
                uespLog.MsgColorType(uespLog.MSG_LOOT, uespLog.itemColor, "You looted "..name.." from the dig site.")
            end
			
        elseif lootType == LOOT_TABLE_ENTRY_TYPE_ANTIQUITY_LEAD then
            qualityColorDef = GetAntiquityQualityColor(quality)
			name = qualityColorDef:Colorize(name)
			
			uespLog.MsgColorType(uespLog.MSG_LOOT, uespLog.itemColor, "You looted a new lead "..name.." from the dig site.")
        end
	end
	--]]
end


function uespLog.OnLootGained (eventCode, receivedBy, itemLink, quantity, itemSound, lootType, self, isPickPocket, questItemIcon, itemId, isStolen, extraLogData)
	local logData = { }
	local posData = uespLog.GetLastTargetData()
	local msgType = "item"
	local rcvType = "looted"
	local icon, sellPrice, meetsUsageRequirement, equipType, itemStyle = GetItemLinkInfo(itemLink)
	local itemType = GetItemLinkItemType(itemLink)
	local itemText, itemColor, itemId, itemLevel, itemData, niceName, niceLink = uespLog.ParseLinkID(itemLink)
	local itemStyleStr = GetItemStyleName(itemStyle)
	local lootMsg = ""
	local diffActivateTime = GetGameTimeSeconds() - uespLog.lastActivateInfo.gameTime
	local diffLootTime = GetGameTimeSeconds() - uespLog.lastLootTargetGameTime
		
	quantity = quantity or 1
	if (quantity == 0) then quantity = 1 end
	
	--local targetName, targetType, targetActionName, targetIsOwned = GetLootTargetInfo()
	--uespLog.DebugMsg("Loot: "..tostring(targetName)..", "..tostring(targetType)..", "..tostring(targetActionName)..", "..tostring(targetIsOwned))
	--uespLog.DebugExtraMsg("Loot: "..tostring(uespLog.lastLootTargetName)..", "..tostring(uespLog.lastLootTargetName1)..", "..tostring(diffActivateTime)..", "..tostring(diffLootTime))
	 	
	if (IsLooting()) then
		uespLog.lastLootUpdateCount = GetNumLootItems()
	else
		uespLog.lastLootUpdateCount = -1
	end

	if (uespLog.currentHarvestTarget ~= nil) then
		posData.x = uespLog.currentHarvestTarget.x
		posData.y = uespLog.currentHarvestTarget.y
		posData.zone = uespLog.currentHarvestTarget.zone
		posData.lastTarget = uespLog.currentHarvestTarget.name
		posData.harvestType = uespLog.currentHarvestTarget.harvestType
		uespLog.lastLootTargetName = uespLog.currentHarvestTarget.name
		msgType = "resource(" .. tostring(posData.harvestType) .. ")"
		rcvType = "harvested"
	elseif (diffActivateTime <= uespLog.MAX_LASTACTIVATE_TIMEDIFF and uespLog.lastActivateInfo.name ~= "") then
		posData.lastTarget = uespLog.lastActivateInfo.name
	elseif (diffLootTime <= uespLog.MAX_LASTLOOT_TIMEDIFF and uespLog.lastLootTargetName1 ~= "") then
		posData.lastTarget = uespLog.lastLootTargetName1
	elseif (uespLog.lastLootTargetName ~= "") then
		posData.lastTarget = uespLog.lastLootTargetName
	else
		uespLog.lastLootTargetName = uespLog.lastTargetData.name
		posData.lastTarget = uespLog.lastLootTargetName
	end
	
	if (lootType == LOOT_TYPE_QUEST_ITEM) then
		msgType = "quest item"
		rcvType = rcvType.." quest item"
	elseif (lootType == LOOT_TYPE_ANTIQUITY_LEAD) then
		msgType = "antiquity lead"
		rcvType = rcvType.." antiquity lead"
		
		if (uespLog.lastAntiquityIdLeadFound > 0) then
			local antiquityName = zo_strformat(SI_ANTIQUITY_NAME_FORMATTER, GetAntiquityName(uespLog.lastAntiquityIdLeadFound ))
			local antiquityQuality = GetAntiquityQuality(uespLog.lastAntiquityIdLeadFound )
			local qualityColorDef = GetAntiquityQualityColor(antiquityQuality)
			local coloredName = qualityColorDef:Colorize(antiquityName)
	
			niceLink = "|r"..coloredName.."|c"..uespLog.itemColor..""
		end
	end
	
	if (isPickPocket) then
		rcvType = "pickpocketed"
		
		logData.ppBonus, logData.ppIsHostile, logData.ppChance, logData.ppDifficulty, logData.ppEmpty, logData.ppResult, logData.ppClassString, logData.ppClass = GetGameCameraPickpocketingBonusInfo()

	elseif (isStolen or uespLog.lastTargetData.action == uespLog.ACTION_STEALFROM or uespLog.lastTargetData.action == uespLog.ACTION_STEAL) then
		rcvType = "stole"
	end
	
	if (not self) then
		rcvType = "looted"
		msgType = "item"
	end	
	
	logData.event = "LootGained"
	logData.itemLink = itemLink
	logData.qnt = quantity
	logData.lootType = lootType
	logData.rvcType = rcvType
	
	if (posData.x == nil or posData.x == "") then
		posData = uespLog.GetPlayerPositionData()
	end
	
	if (itemType == ITEMTYPE_MASTER_WRIT) then
		local linkData = uespLog.ParseItemLinkEx(itemLink)
		local vouchers = math.floor(linkData.potionData/10000 + 0.5)
		
		if (vouchers > 0) then
			lootMsg = lootMsg .. " (" .. vouchers .. " writ vouchers)"
		end
	end
	
	if (posData.lastTarget ~= nil) then
		lootMsg = lootMsg .. " from "..tostring(posData.lastTarget):gsub("%^.*", "")
	end

	if (self) then
		uespLog.AppendDataToLog("all", logData, posData, uespLog.GetTimeData(), extraLogData)
		
		if (extraLogData ~= nil and extraLogData.skippedLoot) then
			uespLog.DebugMsgColor(uespLog.itemColor, "Skipped looting "..niceLink.." (x"..tostring(quantity)..") (prov level "..tostring(extraLogData.tradeType)..")"..lootMsg..".")
		else
			
			if (quantity == 1) then
				uespLog.MsgColorType(uespLog.MSG_LOOT, uespLog.itemColor, "You "..rcvType.." "..niceLink..lootMsg..".")
			else
				uespLog.MsgColorType(uespLog.MSG_LOOT, uespLog.itemColor, "You "..rcvType.." "..niceLink.." (x"..tostring(quantity)..")"..lootMsg..".")
			end
			
			uespLog.TrackLoot(itemLink, quantity, posData.lastTarget)
		end
		
		local money, stolenMoney = GetLootMoney()
		uespLog.DebugExtraMsg("UESP: LootMoney = "..tostring(money)..", stolen = "..tostring(stolenMoney))
	else
		uespLog.MsgColorType(uespLog.MSG_LOOT, uespLog.itemColor, "Someone "..rcvType.." "..msgType.." "..niceLink.." (x"..tostring(quantity)..").")
	end
	
	if (uespLog.IsNirncruxItem(itemLink)) then
		uespLog.PlayNirncruxSound()
	end
	
end


uespLog.CHAPTERINDEX_TO_DISPLAYEDCHAPTER = {
	[0]  = 0,
	[1]  = 8,
	[2]  = 7,
	[3]  = 3,
	[4]  = 9,
	[5]  = 5,
	[6]  = 2,
	[7]  = 12,
	[8]  = 14,
	[9]  = 10,
	[10] = 1,
	[11] = 6,
	[12] = 13,
	[13] = 11,
	[14] = 4,
}


function uespLog.OnStyleLearned (eventCode, styleIndex, chapterIndex)
	-- chapterIndex is *not* the chapter as displayed on the book/item
	--		chapterIndex => Displayed Chapter
	--				0 	=> All Chapters
	--				1 	=> 8 (Helmets)
	--				2	=> 7 (Gloves)	
	--				3 	=> 3 (Boots)
	--				4 	=> 9 (Legs)
	--				5 	=> 5 (Chests)
	--				6 	=> 2 (Belts)
	--				7 	=> 12 (Shoulders)
	--				8 	=> 14 (Swords)
	--				9 	=> 10 (Maces)
	--				10	=> 1 (Axes) 
	--				11 	=> 6 (Daggers)
	--				12 	=> 13 (Staves)
	--				13 	=> 11 (Shields)
	--				14 	=> 4 (Bows)
	--
	uespLog.DebugExtraMsg("OnStyleLearned: "..tostring(styleIndex)..":"..tostring(chapterIndex))

end


function uespLog.OnCraftStationInteract (eventCode, craftSkill, sameStation)
	uespLog.DebugExtraMsg("OnCraftStationInteract: "..tostring(craftSkill))
	uespLog.LastCraftCompletedUsedLLC = false
end


uespLog.EQUIPTYPE_TO_CRAFTBOOKCHAPTER = {
	[EQUIP_TYPE_CHEST] = 5,
	[EQUIP_TYPE_COSTUME] = nil,
	[EQUIP_TYPE_FEET] = 3,
	[EQUIP_TYPE_HAND] = 7,
	[EQUIP_TYPE_HEAD] = 8,
	[EQUIP_TYPE_INVALID] = nil,
	[EQUIP_TYPE_LEGS] = 9,
	[EQUIP_TYPE_MAIN_HAND] = nil,
	[EQUIP_TYPE_NECK] = nil,
	[EQUIP_TYPE_OFF_HAND] = nil,
	[EQUIP_TYPE_ONE_HAND] = nil,
	[EQUIP_TYPE_RING] = nil,
	[EQUIP_TYPE_SHOULDERS] = 12,
	[EQUIP_TYPE_TWO_HAND] = nil,
	[EQUIP_TYPE_WAIST] = 2,
}


uespLog.WEAPONTYPE_TO_CRAFTBOOKCHAPTER = {
	[WEAPONTYPE_AXE] = 1,
	[WEAPONTYPE_BOW] = 4,
	[WEAPONTYPE_DAGGER] = 6,
	[WEAPONTYPE_FIRE_STAFF] = 13,
	[WEAPONTYPE_FROST_STAFF] = 13,
	[WEAPONTYPE_HAMMER] = 10,
	[WEAPONTYPE_HEALING_STAFF] = 13,
	[WEAPONTYPE_LIGHTNING_STAFF] = 13,
	[WEAPONTYPE_NONE] = nil,
	[WEAPONTYPE_PROP] = nil,
	[WEAPONTYPE_RUNE] = nil,
	[WEAPONTYPE_SHIELD] = 11,
	[WEAPONTYPE_SWORD] = 14,
	[WEAPONTYPE_TWO_HANDED_AXE] = 1,
	[WEAPONTYPE_TWO_HANDED_HAMMER] = 10,
	[WEAPONTYPE_TWO_HANDED_SWORD] = 14,
}


uespLog.LastCraftCompletedUsedLLC = false


function uespLog.OnEndCraftStationInteract(event, craftSkill)
	uespLog.LastCraftCompletedUsedLLC = false
end


function uespLog.OnCraftCompleted (eventCode, craftSkill, usingLLC)
	local inspiration = GetLastCraftingResultTotalInspiration()
	local numItemsGained, penalty = GetNumLastCraftingResultItemsAndPenalty()
	local logData = { }
	local craftInteractionType = GetCraftingInteractionType()
	local itemLink = GetLastCraftingResultItemLink(1)
	
	--uespLog.DebugExtraMsg("OnCraftCompleted: "..tostring(craftInteractionType)..":"..tostring(itemLink))
	
	if (usingLLC) then
		uespLog.LastCraftCompletedUsedLLC = true
	else
	
		if (uespLog.LastCraftCompletedUsedLLC) then
			uespLog.LastCraftCompletedUsedLLC = false
			--uespLog.DebugMsg("Skip duplicate event")
			return
		end
		
		uespLog.LastCraftCompletedUsedLLC = false
	end 
	
	logData.event = "CraftComplete"
	logData.craftSkill = craftSkill
	logData.inspiration = inspiration
	logData.qnt = numItemsGained

	uespLog.AppendDataToLog("all", logData, uespLog.GetPlayerPositionData(), uespLog.GetTimeData())
	
	uespLog.AddTotalInspiration(inspiration)
	
	if (inspiration > 0 and uespLog.GetMessageDisplay(uespLog.MSG_INSPIRATION)) then
		uespLog.MsgType(uespLog.MSG_OTHER, "Craft completed with " .. tostring(inspiration) .. " xp ("..tostring(uespLog.GetTotalInspiration()).." since last reset).")
	end
	
    for i = 1, numItemsGained do
		local itemName, icon, stack, sellPrice, meetsUsageRequirement, equipType, itemType, itemStyle, quality, itemSoundCategory, itemInstanceId = GetLastCraftingResultItemInfo(i)
		
		logData = { }
		logData.event = "CraftComplete::Result"
		logData.itemName = itemName
		logData.type = itemType
		logData.equipType = equipType
		logData.quality = quality	
		logData.value = sellPrice
		logData.icon = icon
		logData.qnt = stack
		logData.itemInstanceId = itemInstanceId
		
		uespLog.AppendDataToLog("all", logData)
		
		local itemLink = GetLastCraftingResultItemLink(i)
		if (itemLink == nil or itemLink == "") then itemLink = itemName end
		
		uespLog.MsgColorType(uespLog.MSG_OTHER, uespLog.itemColor, "You crafted item ".. tostring(itemLink) .." (x"..tostring(stack)..").")
		uespLog.TrackLoot(itemLink, stack)
	end
	
	if (numItemsGained == 0) then
		uespLog.DebugExtraMsg("No items crafted")
	else
		uespLog.TrackLootSource("crafted")
	end	
end


function uespLog.OnInventoryItemUsed (eventCode, itemSoundCategory)
	uespLog.DebugExtraMsg("UESP: OnInventoryItemUsed sound="..tostring(itemSoundCategory))
	
	-- Old Event no longer called?
	
	--uespLog.OnUseItem(eventCode, uespLog.lastItemLinkUsed_BagId, uespLog.lastItemLinkUsed_SlotIndex, uespLog.lastItemLinkUsed, itemSoundCategory)
end


function uespLog.OnOpenFootlocker(eventCode, bagId, slotIndex, itemLink, itemSoundCategory)
	local logData = { }
	local itemType = GetItemLinkItemType(itemLink) --ITEMTYPE_CONTAINER
	
	uespLog.DebugExtraMsg("UESP: OnOpenFootlocker "..tostring(itemLink).."("..tostring(bagId)..","..tostring(slotIndex)..") sound="..tostring(itemSoundCategory)..", type="..tostring(itemType))
	
	uespLog.lastItemUsed = itemLink
	uespLog.lastItemUsedGameTime = GetGameTimeMilliseconds()

	local itemName = GetItemLinkName(itemLink)
	logData.tradeType = CRAFTING_TYPE_INVALID
	
	if (uespLog.BeginsWith(itemName, "Alchemist's")) then
		logData.tradeType = CRAFTING_TYPE_ALCHEMY
	elseif (uespLog.BeginsWith(itemName, "Clothier's")) then
		logData.tradeType = CRAFTING_TYPE_CLOTHIER
	elseif (uespLog.BeginsWith(itemName, "Blacksmith's")) then
		logData.tradeType = CRAFTING_TYPE_BLACKSMITHING
	elseif (uespLog.BeginsWith(itemName, "Enchanter's")) then
		logData.tradeType = CRAFTING_TYPE_ENCHANTING
	elseif (uespLog.BeginsWith(itemName, "Provisioner's")) then
		logData.tradeType = CRAFTING_TYPE_PROVISIONING
	elseif (uespLog.BeginsWith(itemName, "Woodworker's")) then
		logData.tradeType = CRAFTING_TYPE_WOODWORKING
	elseif (uespLog.BeginsWith(itemName, "Jewelry Crafter's")) then
		logData.tradeType = CRAFTING_TYPE_JEWELRYCRAFTING
	end
	
	logData.hirelingLevel, logData.craftLevel = uespLog.GetHirelingLevel(logData.tradeType)
	logData.event = "OpenFootLocker"
	logData.itemName = itemName
	logData.sound = itemSoundCategory
	logData.itemLink = itemLink
	logData.characterName = GetUnitName("player")
	uespLog.AppendDataToLog("all", logData)
	uespLog.MsgType(uespLog.MSG_LOOT, "Footlocker "..tostring(itemLink).." opened.")
	
	uespLog.lastTargetData.action = "opened"
	local x, y, z, zone = uespLog.GetUnitPosition(unitTag)
	
	uespLog.lastTargetData.x = x	
	uespLog.lastTargetData.y = y
	uespLog.lastTargetData.zone = zone
	uespLog.lastTargetData.name = "footlocker"
	uespLog.lastTargetData.itemLink = itemLink
	
	if (GetUnitRawWorldPosition ~= nil) then
		uespLog.lastTargetData.worldzoneid, uespLog.lastTargetData.worldx, uespLog.lastTargetData.worldy, uespLog.lastTargetData.worldz = GetUnitRawWorldPosition("player")
	end
	
	uespLog.lastItemLinkUsed = ""
	uespLog.lastItemLinkUsed_BagId = -1
	uespLog.lastItemLinkUsed_SlotIndex = -1
	uespLog.lastItemLinkUsed_itemLinks = {}
	uespLog.lastItemLinkUsed_Name = ""
	uespLog.lastItemLinkUsed_itemNames = {}
end


function uespLog.OnInventorySlotUpdate (eventCode, bagId, slotIndex, isNewItem, itemSoundCategory, updateReason, stackAmountChange)
	local linkId = tostring(bagId) .. ":" .. tostring(slotIndex)
	local lastLinkUsed = uespLog.lastItemLinkUsed_itemLinks[linkId] or uespLog.lastItemLinkUsed
	local lastLinkName =  uespLog.lastItemLinkUsed_itemNames[linkId] or uespLog.lastItemLinkUsed_Name
	local itemName = GetItemName(bagId, slotIndex)
	local itemLink = GetItemLink(bagId, slotIndex, LINK_STYLE_BRACKETS)
	
	if (itemLink == "" or itemName == "") then
		itemLink = lastLinkUsed
		itemName = lastLinkName
	end
	
	local itemId = uespLog.GetItemLinkID(itemLink)
	
	--uespLog.DebugExtraMsg("UESP: Inventory slot("..tostring(bagId)..","..tostring(slotIndex)..") update for "..itemName..", isNew "..tostring(isNewItem)..", reason "..tostring(updateReason)..", sound "..tostring(itemSoundCategory)..", qnt="..tostring(stackAmountChange)..", isDigging = "..tostring(uespLog.isDiggingAntiquity))
	--uespLog.DebugExtraMsg("LastTarget: "..tostring(uespLog.lastTargetData.name))

		-- Skip durability updates or items already logged
	if (updateReason == INVENTORY_UPDATE_REASON_DURABILITY_CHANGE) then
		--uespLog.DebugExtraMsg("UESP: Skipping inventory slot update for "..itemName..", reason "..tostring(updateReason)..", sound "..tostring(itemSoundCategory))
		return
	end
	
	if (itemSoundCategory == ITEM_SOUND_CATEGORY_BOOSTER) then
		uespLog.LogInventoryItem(bagId, slotIndex, "SlotUpdate")
		return
	elseif (itemSoundCategory == ITEM_SOUND_CATEGORY_LURE and (bagId == BAG_BACKPACK or bagId == BAG_VIRTUAL) and not isNewItem) then
		local action, name = GetGameCameraInteractableActionInfo()
		
        if (action == GetString(SI_GAMECAMERAACTIONTYPE17) and name == uespLog.FISHING_HOLE and not SCENE_MANAGER:IsInUIMode()) then
			uespLog.OnFishingReelInReady(0, itemLink, itemName, bagId, slotIndex)
		end
		
	elseif (itemSoundCategory == ITEM_SOUND_CATEGORY_FOOTLOCKER and not isNewItem and stackAmountChange == 0) then
		
		uespLog.OnOpenFootlocker(eventCode, bagId, slotIndex, lastLinkUsed, itemSoundCategory)
		
	elseif ((itemSoundCategory == ITEM_SOUND_CATEGORY_FOOD or itemSoundCategory == ITEM_SOUND_CATEGORY_DRINK) and stackAmountChange == -1) then
	
		uespLog.OnEatDrinkItem(lastLinkUsed)
		
		uespLog.lastItemLinkUsed = ""
		uespLog.lastItemLinkUsed_BagId = -1
		uespLog.lastItemLinkUsed_SlotIndex = -1
		uespLog.lastItemLinkUsed_itemLinks = {}
		uespLog.lastItemLinkUsed_Name = ""
		uespLog.lastItemLinkUsed_itemNames = {}
	elseif ((itemId == 69434 or string.lower(itemName) == "merethic restorative resin")) then
		uespLog.UsedMerethicResin = true
	end
	
	if (not isNewItem) then
	
		if (itemType == ITEMTYPE_CONTAINER) then
			uespLog.DebugExtraMsg("Opened Container: "..tostring(itemName))
		end

		--uespLog.DebugExtraMsg("UESP: Skipping inventory slot update for "..itemName..", old, reason "..tostring(updateReason)..", sound "..tostring(itemSoundCategory))
		return
	end
	
	local usedDeltaTime = GetGameTimeMilliseconds() - (uespLog.lastItemUsedGameTime or 0)
	local usedItemType = GetItemLinkItemType(uespLog.lastItemUsed)
	local itemType = GetItemLinkItemType(itemLink)
	local lastItemLinkUsedDeltaTime = GetGameTimeMilliseconds() - uespLog.lastItemLinkTime
	
		-- Update receiving items from Shadowy Supplier
	if (updateReason == 0 and isNewItem and uespLog.lastTargetData.name == "Remains-Silent") then
		-- Now logged in OnLootGained())
		--uespLog.MsgColorType(uespLog.MSG_LOOT, uespLog.itemColor, "You received "..tostring(itemLink).." from "..tostring(uespLog.lastTargetData.name).."!")
		--uespLog.TrackLoot(itemLink, 1, "Remains-Silent")
	
			-- Using fish
	-- elseif (usedItemType == ITEMTYPE_FISH and itemType == ITEMTYPE_INGREDIENT and usedDeltaTime < 2500) then
	elseif (itemSoundCategory == ITEM_SOUND_CATEGORY_ANIMAL_COMPONENT and stackAmountChange == 1 and not uespLog.isDiggingAntiquity and uespLog.lastItemLinkUsed ~= "" and lastItemLinkUsedDeltaTime < 1) then
		uespLog.MsgColorType(uespLog.MSG_LOOT, uespLog.itemColor, "You created "..itemLink.." from "..tostring(uespLog.lastItemLinkUsed).."!")
		
		uespLog.lastItemLinkUsed = ""
		uespLog.lastItemLinkUsed_BagId = -1
		uespLog.lastItemLinkUsed_SlotIndex = -1
		uespLog.lastItemLinkUsed_itemLinks = {}
		uespLog.lastItemLinkUsed_Name = ""
		uespLog.lastItemLinkUsed_itemNames = {}
	
		-- Update creation of glass motif chapter
	elseif ((uespLog.UsedMerethicResin or itemSoundCategory == ITEM_SOUND_CATEGORY_BOOK) and not uespLog.isDiggingAntiquity) then
	
		if (string.find(string.lower(itemName), "crafting motif 16:") ~= nil) then
			uespLog.MsgColor(uespLog.itemColor, "You used a Merethic Resin to create "..tostring(itemLink).."!")
		end
		
		uespLog.UsedMerethicResin = false
	elseif (itemType == ITEMTYPE_CONTAINER) then
		
		uespLog.CheckAutoOpenContainer(bagId, slotIndex)
		
		-- TODO: Temporary check for new antiquity items
	elseif (updateReason == 0 and isNewItem and uespLog.isDiggingAntiquity) then
		--local diffTime = GetGameTimeSeconds() - uespLog.lastAntiquityGameOver
		--diffTime < uespLog.MAX_LASTANTIQUITY_TIMEDIFF
		
		uespLog.MsgColorType(uespLog.MSG_LOOT, uespLog.itemColor, "You looted "..tostring(itemLink).." from the dig site.")
		uespLog.TrackLoot(itemLink, 1, "Dig Site")
	end
	
	uespLog.LogInventoryItem(bagId, slotIndex, "SlotUpdate")
end


function uespLog.OnTargetChange (eventCode)
    local unitTag = "reticleover"
    local unitType = GetUnitType(unitTag)
	
		--COMBAT_UNIT_TYPE_GROUP
		--COMBAT_UNIT_TYPE_NONE
		--COMBAT_UNIT_TYPE_OTHER
		--COMBAT_UNIT_TYPE_PLAYER
		--COMBAT_UNIT_TYPE_PLAYER_PET

    if (unitType == 2) then -- NPC, COMBAT_UNIT_TYPE_OTHER?
        local name = GetUnitName(unitTag)
        local x, y, z, zone = uespLog.GetUnitPosition(unitTag)
		local gameTime = GetGameTimeMilliseconds()
		local diffTime = gameTime - uespLog.lastOnTargetChangeGameTime
		local active = IsPlayerInteractingWithObject()
		
        if (name == nil or name == "" or x <= 0 or y <= 0 or active) then
            return
        end
		
		--if (uespLog.lastTargetData.name ~= name) then
			--uespLog.DebugExtraMsg("Target changed to "..tostring(name))
		--end
				
		uespLog.lastTargetData.x = x
		uespLog.lastTargetData.y = y
		uespLog.lastTargetData.zone = zone
		uespLog.lastTargetData.name = name
		
		if (GetUnitRawWorldPosition ~= nil) then
			uespLog.lastTargetData.worldzoneid, uespLog.lastTargetData.worldx, uespLog.lastTargetData.worldy, uespLog.lastTargetData.worldz = GetUnitRawWorldPosition("player")
		end
		
        local level = GetUnitLevel(unitTag)
		local gender = GetUnitGender(unitTag)
		local class = GetUnitClass(unitTag)   	-- Empty?
		local race = GetUnitRace(unitTag)		-- Empty?
		local difficulty = GetUnitDifficulty(unitTag)
		local currentHp, maxHp, effectiveHp = GetUnitPower(unitTag, POWERTYPE_HEALTH)
		local currentMg, maxMg, effectiveMg = GetUnitPower(unitTag, POWERTYPE_MAGICKA)
		local currentSt, maxSt, effectiveSt = GetUnitPower(unitTag, POWERTYPE_STAMINA)
		
		uespLog.lastTargetData.maxHp = maxHp
		uespLog.lastTargetData.maxMg = maxMg
		uespLog.lastTargetData.maxSt = maxSt
		uespLog.lastTargetData.level = level
		uespLog.lastTargetData.effectiveLevel = GetUnitEffectiveLevel(unitTag)
		uespLog.lastTargetData.race = race
		uespLog.lastTargetData.class = class
		uespLog.lastTargetData.type = unitType		
		
		uespLog.UpdateTargetHealthData(name, unitTag, maxHp)
		
		if (uespLog.IsIgnoredNPC(name)) then
			return
		end
				
		if (name == uespLog.lastOnTargetChange or diffTime < uespLog.MIN_TARGET_CHANGE_TIMEMS) then
			return
		end
		
		uespLog.lastOnTargetChange = name
		uespLog.lastOnTargetChangeGameTime = gameTime
		
		local logData = { }
		
		logData.event = "TargetChange"
		logData.name = name
		logData.level = level
		logData.gender = gender
		logData.difficulty = difficulty
		logData.maxHp = maxHp
		logData.maxMg = maxMg
		logData.maxSt = maxSt
		logData.reaction = GetUnitReaction(unitTag)
		
		uespLog.AppendDataToLog("all", logData, uespLog.GetLastTargetData(), uespLog.GetTimeData())
		
		uespLog.MsgType(uespLog.MSG_NPC, "UESP: Found Npc "..name.." ("..maxHp.." HP)")
	elseif (unitType == COMBAT_UNIT_TYPE_PLAYER) then
		uespLog.lastOnTargetChange = ""
	elseif (unitType ~= 0) then
		--local name = GetUnitName(unitTag)
		--uespLog.DebugMsg("Other Target: "..tostring(name))
		
		uespLog.lastTargetData.level = ""
		uespLog.lastTargetData.effectiveLevel = ""
		uespLog.lastTargetData.race = ""
		uespLog.lastTargetData.class = ""
		uespLog.lastTargetData.type = unitType		
		uespLog.lastOnTargetChange = ""
	else
		uespLog.lastOnTargetChange = ""
    end
	
end


function uespLog.OnSynergyAbilityGained (eventCode, synergyBuffSlot, grantedAbilityName, beginTime, endTime, iconName)
	--EVENT_SYNERGY_ABILITY_GAINED (integer synergyBuffSlot, string grantedAbilityName, number beginTime, number endTime, string iconName)
	deltaTime = endTime - beginTime
	uespLog.DebugExtraMsg("Gained synergy "..grantedAbilityName.." for "..tostring(deltaTime).."s")
end


function uespLog.OnSynergyAbilityLost (eventCode, synergyBuffSlot)
	--EVENT_SYNERGY_ABILITY_LOST (integer synergyBuffSlot)
	uespLog.DebugExtraMsg("Lost synergy #"..synergyBuffSlot)
end


function uespLog.OnEffectChanged (eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId)
	--EVENT_EFFECT_CHANGED (integer changeType, integer effectSlot, string effectName, string unitTag, number beginTime, number endTime, integer stackCount, string iconName, string buffType, integer effectType, integer abilityType, integer statusEffectType)
	local playerUnitName = GetRawUnitName('player')
	local tempData = uespLog.savedVars.tempData.data
	local msg = ""
	
	msg = msg .. "'EffectChanged',"
	msg = msg .. "'" .. tostring(GetGameTimeMilliseconds()) .. "',"
	msg = msg .. "'" .. tostring(changeType) .. "',"
	msg = msg .. "'" .. tostring(effectSlot) .. "',"
	msg = msg .. "'" .. tostring(effectName) .. "',"
	msg = msg .. "'" .. tostring(unitTag) .. "',"
	msg = msg .. "'" .. tostring(beginTime) .. "',"
	msg = msg .. "'" .. tostring(endTime) .. "',"
	msg = msg .. "'" .. tostring(stackCount) .. "',"
	msg = msg .. "'" .. tostring(iconName) .. "',"
	msg = msg .. "'" .. tostring(buffType) .. "',"
	msg = msg .. "'" .. tostring(effectType) .. "',"
	msg = msg .. "'" .. tostring(abilityType) .. "',"
	msg = msg .. "'" .. tostring(statusEffectType) .. "',"
	msg = msg .. "'" .. tostring(unitName) .. "',"
	msg = msg .. "'" .. tostring(unitId) .. "',"
	msg = msg .. "'" .. tostring(abilityId)
	tempData[#tempData + 1] = msg
	
	--if (abilityId == 23998) then
	--if (playerUnitName == unitName) then
		--uespLog.DebugExtraMsg("Effect Changed: "..tostring(abilityId)..":"..effectName.." unit:"..unitTag.." type:"..changeType.."  name:"..tostring(unitName).." id:"..tostring(unitId))
	--end
end


uespLog.EVENT_TYPE_IGNORE = 0
uespLog.EVENT_TYPE_DAMAGE = 1
uespLog.EVENT_TYPE_HEAL = 2
uespLog.EVENT_TYPE_DAMAGE_DEFLECTED = 3
uespLog.EVENT_TYPE_OTHER = 4
uespLog.EVENT_TYPE_DRAIN = 5
uespLog.EVENT_TYPE_ENERGIZE = 6


function uespLog.GetCombatEventDetails(result, isError, hitValue, powerType, damageType)
	-- Returns: eventType, hitCount, critCount, dotCount, dotCritCount 

	if ( isError ) then
		return uespLog.EVENT_TYPE_IGNORE, 0, 0, 0, 0
	end

	if ( hitValue == 0 ) then
		return uespLog.EVENT_TYPE_IGNORE, 0, 0, 0, 0
	end

	if ( powerType == POWERTYPE_INVALID or powerType == POWERTYPE_MOUNT_STAMINA ) then
		return uespLog.EVENT_TYPE_IGNORE, 0, 0, 0, 0
	end

	if ( damageType == DAMAGE_TYPE_NONE ) then
		return uespLog.EVENT_TYPE_OTHER, 0, 0, 0, 0
	end

	if ( result == ACTION_RESULT_HEAL ) then
		return uespLog.EVENT_TYPE_HEAL, 1, 0, 0, 0
	end

	if ( result == ACTION_RESULT_CRITICAL_HEAL ) then
		return uespLog.EVENT_TYPE_HEAL, 1, 1, 0, 0
	end

	if ( result == ACTION_RESULT_HOT_TICK ) then
		return uespLog.EVENT_TYPE_HEAL, 0, 0, 1, 0
	end

	if ( result == ACTION_RESULT_HOT_TICK_CRITICAL ) then
		return uespLog.EVENT_TYPE_HEAL, 0, 0, 1, 1
	end

	if ( result == ACTION_RESULT_BLOCKED or
		 result == ACTION_RESULT_DAMAGE_SHIELDED or
		 result == ACTION_RESULT_PARRIED or
		 result == ACTION_RESULT_REFLECTED or
		 result == ACTION_RESULT_IMMUNE ) then
		 
		return uespLog.EVENT_TYPE_DAMAGE, 0, 0, 0, 0
	end

	if ( result == ACTION_RESULT_ABSORBED or
		 result == ACTION_RESULT_BLOCKED_DAMAGE or
		 result == ACTION_RESULT_FALL_DAMAGE or
		 result == ACTION_RESULT_PARTIAL_RESIST or
		 result == ACTION_RESULT_PRECISE_DAMAGE or
		 result == ACTION_RESULT_WRECKING_DAMAGE ) then
		return uespLog.EVENT_TYPE_DAMAGE, 0, 0, 0, 0
	end

	if ( result == ACTION_RESULT_DAMAGE) then
		return uespLog.EVENT_TYPE_DAMAGE, 1, 0, 0, 0
	end

	if ( result == ACTION_RESULT_CRITICAL_DAMAGE) then
		return uespLog.EVENT_TYPE_DAMAGE, 1, 1, 0, 0
	end

	if ( result == ACTION_RESULT_DOT_TICK) then
		return uespLog.EVENT_TYPE_DAMAGE, 0, 0, 1, 0
	end

	if ( result == ACTION_RESULT_DOT_TICK_CRITICAL) then
		return uespLog.EVENT_TYPE_DAMAGE, 0, 0, 1, 1
	end
	
	if ( result == ACTION_RESULT_POWER_DRAIN ) then
		return uespLog.EVENT_TYPE_DRAIN, 0, 0, 0, 0
	end
	
	if ( result == ACTION_RESULT_POWER_ENERGIZE ) then
		return uespLog.EVENT_TYPE_ENERGIZE, 0, 0, 0, 0
	end
	
	return uespLog.EVENT_TYPE_IGNORE, 0, 0, 0, 0
end


function uespLog.OnCombatEvent (eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, isLogged, sourceUnitId, targetUnitId, abilityId)
	
	--[[
	local msg = ""
	local tempData = uespLog.savedVars.tempData.data
	
	msg = msg .. "'CombatEvent',"
	msg = msg .. "'" .. tostring(GetGameTimeMilliseconds()) .. "',"
	msg = msg .. "'" .. tostring(result) .. "',"
	msg = msg .. "'" .. tostring(isError) .. "',"
	msg = msg .. "'" .. tostring(abilityName) .. "',"
	msg = msg .. "'" .. tostring(abilityGraphic) .. "',"
	msg = msg .. "'" .. tostring(abilityActionSlotType) .. "',"
	msg = msg .. "'" .. tostring(sourceName) .. "',"
	msg = msg .. "'" .. tostring(sourceType) .. "',"
	msg = msg .. "'" .. tostring(targetName) .. "',"
	msg = msg .. "'" .. tostring(targetType) .. "',"
	msg = msg .. "'" .. tostring(hitValue) .. "',"
	msg = msg .. "'" .. tostring(powerType) .. "',"
	msg = msg .. "'" .. tostring(damageType) .. "',"
	msg = msg .. "'" .. tostring(isLogged) .. "',"
	msg = msg .. "'" .. tostring(sourceUnitId) .. "',"
	msg = msg .. "'" .. tostring(targetUnitId) .. "',"
	msg = msg .. "'" .. tostring(abilityId)
	tempData[#tempData + 1] = msg	
	--]]

	if (sourceType ~= COMBAT_UNIT_TYPE_PLAYER and targetType ~= COMBAT_UNIT_TYPE_PLAYER) then
	
		if (result == 2262) then
			--uespLog.DebugMsg("Death Not Player: Result: "..tostring(result)..",  sourceType: "..tostring(sourceType)..",  damageType: "..tostring(damageType)..",  name: "..tostring(abilityName)..",  hitValue: "..tostring(hitValue).."  srcId: "..tostring(sourceUnitId).." ("..tostring(sourceName)..")".."  tarId: "..tostring(targetUnitId).." w("..tostring(targetName)..")")
			uespLog.UpdateFightTargetDeath(targetUnitId, targetName)
		end
		
		return
	end

	if ((result == 2262 or result == 2260) and sourceType == COMBAT_UNIT_TYPE_PLAYER) then
		--uespLog.DebugMsg("Death: "..tostring(result)..",  sourceType: "..tostring(sourceType)..",  damageType: "..tostring(damageType)..",  name: "..tostring(abilityName)..",  hitValue: "..tostring(hitValue).."  srcId: "..tostring(sourceUnitId).." ("..tostring(sourceName)..")".."  tarId: "..tostring(targetUnitId).." ("..tostring(targetName)..")")
		uespLog.UpdateFightTargetDeath(targetUnitId, targetName)
	else
		uespLog.UpdateRecentFightTargetId(targetUnitId, targetName)
		--uespLog.DebugMsg("CE Player: Result: "..tostring(result)..",  sourceType: "..tostring(sourceType)..",  damageType: "..tostring(damageType)..",  name: "..tostring(abilityName)..",  hitValue: "..tostring(hitValue).."  srcId: "..tostring(sourceUnitId).." ("..tostring(sourceName)..")".."  tarId: "..tostring(targetUnitId).." ("..tostring(targetName)..")")
	end
	
	hitValue = tonumber(hitValue)
	
	local display = false
	local color = uespLog.defaultColor
	local typeString = ""
	local currentValue = 0
	
	local gameTime = (GetGameTimeMilliseconds() - uespLog.baseTrackStatGameTime) / 1000 
	local gameTimeStr = string.format("%7.3f", gameTime)
	
	local spellDamage = GetPlayerStat(STAT_SPELL_POWER, STAT_BONUS_OPTION_APPLY_BONUS, STAT_SOFT_CAP_OPTION_APPLY_SOFT_CAP)
	local weaponDamage = GetPlayerStat(STAT_POWER, STAT_BONUS_OPTION_APPLY_BONUS, STAT_SOFT_CAP_OPTION_APPLY_SOFT_CAP)

	if (uespLog.lastPlayerSpellDamage ~= spellDamage and uespLog.GetTrackStat("Spell Damage")) then
		local value = spellDamage - uespLog.lastPlayerSpellDamage
		uespLog.lastPlayerSpellDamage = spellDamage
		
		if (value > 0) then
			uespLog.MsgColor(color, tostring(gameTimeStr) .. ": +"..tostring(value).." Spell Damage")
		else
			uespLog.MsgColor(color, tostring(gameTimeStr) .. ": "..tostring(value).." Spell Damage")
		end
	end
	
	if (uespLog.lastPlayerWeaponDamage ~= weaponDamage and uespLog.GetTrackStat("Weapon Damage")) then
		local value = weaponDamage - uespLog.lastPlayerWeaponDamage
		uespLog.lastPlayerWeaponDamage = weaponDamage
		
		if (value > 0) then
			uespLog.MsgColor(color, tostring(gameTimeStr) .. ": +"..tostring(value).." Weapon Damage")
		else
			uespLog.MsgColor(color, tostring(gameTimeStr) .. ": "..tostring(value).." Weapon Damage")
		end
	end
	
	local eventType, hitCount, critCount, dotCount, dotCritCount = uespLog.GetCombatEventDetails(result, isError, hitValue, powerType, damageType)
	
	if (eventType == uespLog.EVENT_TYPE_IGNORE) then
		return
	elseif (eventType == uespLog.EVENT_TYPE_DAMAGE) then
		hitValue = -tonumber(hitValue)
		powerType = POWERTYPE_HEALTH
	elseif (eventType == uespLog.EVENT_TYPE_HEAL) then
		powerType = POWERTYPE_HEALTH
	elseif (eventType == uespLog.EVENT_TYPE_DRAIN) then
		hitValue = -tonumber(hitValue)
	end
	
	if (powerType == POWERTYPE_STAMINA and uespLog.GetTrackStat(POWERTYPE_STAMINA)) then
		display = true
		typeString = "stamina"
		color = uespLog.trackStatStaColor
		uespLog.lastPlayerST = GetUnitPower("player", POWERTYPE_STAMINA)
		currentValue = uespLog.lastPlayerST
	elseif (powerType == POWERTYPE_MAGICKA and uespLog.GetTrackStat(POWERTYPE_MAGICKA)) then
		display = true
		typeString = "magicka"
		uespLog.lastPlayerMG = GetUnitPower("player", POWERTYPE_MAGICKA)
		currentValue = uespLog.lastPlayerMG
		color = uespLog.trackStatMagColor
	elseif (powerType == POWERTYPE_HEALTH and uespLog.GetTrackStat(POWERTYPE_HEALTH)) then
		display = true
		typeString = "health"
		uespLog.lastPlayerHP = GetUnitPower("player", POWERTYPE_HEALTH)
		currentValue = uespLog.lastPlayerHP
		color = uespLog.trackStatHeaColor
	elseif (powerType == POWERTYPE_ULTIMATE and uespLog.GetTrackStat(POWERTYPE_ULTIMATE)) then
		display = true
		typeString = "ultimate"
		uespLog.lastPlayerUT = GetUnitPower("player", POWERTYPE_ULTIMATE)
		currentValue = uespLog.lastPlayerUT
		color = uespLog.trackStatUltColor
	end
	
	if (not display or hitValue == 0) then
		--uespLog.DebugMsg("Not Stats: Result: "..tostring(result)..",  sourceType: "..tostring(sourceType)..",  damageType: "..tostring(damageType)..",  name: "..tostring(abilityName)..",  hitValue: "..tostring(hitValue))
		return
	end
	
	if (hitValue > 0) then
		uespLog.MsgColor(color, tostring(gameTimeStr) .. ": +"..tostring(hitValue).." "..typeString.." from "..tostring(abilityName))
	else
		uespLog.MsgColor(color, tostring(gameTimeStr) .. ": "..tostring(hitValue).." "..typeString.." from "..tostring(abilityName))
	end
	
	--uespLog.DebugMsg("Result: "..tostring(result)..",  sourceType: "..tostring(sourceType)..",  damageType: "..tostring(damageType)..",  slotType: "..tostring(abilityActionSlotType)..",  powerType: "..powerType..", id: "..abilityId)
end


function uespLog.OnPowerUpdate (eventCode, unitTag, powerIndex, powerType, powerValue, powerMax, powerEffectiveMax)
	--EVENT_POWER_UPDATE (string unitTag, luaindex powerIndex, integer powerType, integer powerValue, integer powerMax, integer powerEffectiveMax)
		
	if (unitTag ~= "player") then
		return
	end
	
	local gameMS = GetGameTimeMilliseconds()
	local gameTime = (gameMS - uespLog.baseTrackStatGameTime) / 1000 
	local diff = 0
	local typeString = ""
	local display = false
	local color = uespLog.defaultColor
	local currentValue = 0
	local combatRegen = 0
	local idleRegen = 0
	
	if (powerType == POWERTYPE_HEALTH) then
		diff = powerValue - uespLog.lastPlayerHP
		uespLog.lastPlayerHP = GetUnitPower("player", POWERTYPE_HEALTH)
		currentValue = uespLog.lastPlayerHP
		typeString = "health"
		if (uespLog.GetTrackStat(POWERTYPE_HEALTH)) then display = true end
		color = uespLog.trackStatHeaColor
		
		combatRegen = GetPlayerStat(STAT_HEALTH_REGEN_COMBAT, STAT_BONUS_OPTION_APPLY_BONUS, STAT_SOFT_CAP_OPTION_APPLY_SOFT_CAP)
		idleRegen = GetPlayerStat(STAT_HEALTH_REGEN_IDLE, STAT_BONUS_OPTION_APPLY_BONUS, STAT_SOFT_CAP_OPTION_APPLY_SOFT_CAP)
		
	elseif (powerType == POWERTYPE_MAGICKA) then
		diff = powerValue - uespLog.lastPlayerMG
		uespLog.lastPlayerMG = GetUnitPower("player", POWERTYPE_MAGICKA)
		currentValue = uespLog.lastPlayerMG
		typeString = "magicka"
		if (uespLog.GetTrackStat(POWERTYPE_MAGICKA)) then display = true end
		color = uespLog.trackStatMagColor
		
		combatRegen = GetPlayerStat(STAT_MAGICKA_REGEN_COMBAT, STAT_BONUS_OPTION_APPLY_BONUS, STAT_SOFT_CAP_OPTION_APPLY_SOFT_CAP)
		idleRegen = GetPlayerStat(STAT_MAGICKA_REGEN_IDLE, STAT_BONUS_OPTION_APPLY_BONUS, STAT_SOFT_CAP_OPTION_APPLY_SOFT_CAP)
		
	elseif (powerType == POWERTYPE_STAMINA) then
		diff = powerValue - uespLog.lastPlayerST
		uespLog.lastPlayerST = GetUnitPower("player", POWERTYPE_STAMINA)
		currentValue = uespLog.lastPlayerST
		typeString = "stamina"
		if (uespLog.GetTrackStat(POWERTYPE_STAMINA)) then display = true end
		color = uespLog.trackStatStaColor
		
		combatRegen = GetPlayerStat(STAT_STAMINA_REGEN_COMBAT, STAT_BONUS_OPTION_APPLY_BONUS, STAT_SOFT_CAP_OPTION_APPLY_SOFT_CAP)
		idleRegen = GetPlayerStat(STAT_STAMINA_REGEN_IDLE, STAT_BONUS_OPTION_APPLY_BONUS, STAT_SOFT_CAP_OPTION_APPLY_SOFT_CAP)
		
	elseif (powerType == POWERTYPE_ULTIMATE) then
		diff = powerValue - uespLog.lastPlayerUT
		uespLog.lastPlayerUT = GetUnitPower("player", POWERTYPE_ULTIMATE)
		currentValue = uespLog.lastPlayerUT
		typeString = "ultimate"
		if (uespLog.GetTrackStat(POWERTYPE_ULTIMATE)) then display = true end
		color = uespLog.trackStatUltColor
		
		combatRegen = -10000
		idleRegen = -10000
		
	else
		return
	end
	
	local gameTimeStr = string.format("%7.3f", gameTime)
	local isInCombat = IsUnitInCombat("player")
	local sourceName = "unknown"
	
	if (not isInCombat) then
		if (diff == idleRegen) then
			sourceName = "idle regen"
		elseif (diff > 0 and diff < idleRegen and currentValue == powerMax) then
			sourceName = "idle regen"
		end
	else
		if (diff == combatRegen) then
			sourceName = "combat regen"
		elseif (diff > 0 and diff < combatRegen and currentValue == powerMax) then
			sourceName = "combat regen"
		end
	end
	
	if (diff < 0) then
		diff = math.abs(diff)
		
		if (display) then
			--uespLog.MsgColor(color, tostring(gameTimeStr) .. ": -"..tostring(diff).." "..typeString..",  "..powerValue.."/"..currentValue..",  "..gameMS/1000)
			uespLog.MsgColor(color, tostring(gameTimeStr) .. ": -"..tostring(diff).." "..typeString.." from "..sourceName)
		end
		
		--uespLog.DebugExtraMsg("Lost "..tostring(diff).." "..typeString)
	elseif (diff > 0) then
		
		if (display) then
			--uespLog.MsgColor(color, tostring(gameTimeStr) .. ": +"..tostring(diff).." "..typeString..",  "..powerValue.."/"..currentValue..",  "..gameMS/1000)
			uespLog.MsgColor(color, tostring(gameTimeStr) .. ": +"..tostring(diff).." "..typeString.." from "..sourceName)
		end
		
		--uespLog.DebugExtraMsg("Gained "..tostring(diff).." "..typeString)
	else
		--uespLog.DebugExtraMsg("powerIndex = "..tostring(powerIndex)..", type="..tostring(powerType)..", value="..tostring(powerValue)..", max="..tostring(powerMax)..", effMax="..tostring(powerEffectiveMax))
		--uespLog.DebugExtraMsg("Lost "..tostring(diff).." "..typeString)
	end
	
end


function uespLog.OnFoundSkyshard ()
	local logData = { }
	
	logData.event = "Skyshard"
	
	uespLog.AppendDataToLog("all", logData, uespLog.GetCurrentTargetData(), uespLog.GetTimeData())
	
		-- Message is already output in OnSkillPointsChanged event
	--uespLog.MsgType(uespLog.MSG_OTHER, "UESP: Found skyshard!")
end


uespLog.lastFoundTreasure = {
	name = "",
	gameTime = 0,
}

uespLog.FOUNDTREASURE_GAMETIME_MINDIFF = 10


function uespLog.OnFoundTreasure (name, lockQuality)
	local logData = { }
	local qualityMsg = GetString("SI_LOCKQUALITY", lockQuality)
	local gameTimeDiff = GetGameTimeSeconds() - uespLog.lastFoundTreasure.gameTime
	
	logData.event = "FoundTreasure"
	logData.name = name
	logData.lockQuality = lockQuality
	
	uespLog.AppendDataToLog("all", logData, uespLog.GetCurrentTargetData(), uespLog.GetTimeData())
	
	if (name == uespLog.lastFoundTreasure.name and gameTimeDiff <= uespLog.FOUNDTREASURE_GAMETIME_MINDIFF) then
		uespLog.lastFoundTreasure.gameTime = GetGameTimeSeconds()
		return
	end
	
	if (qualityMsg ~= "") then
		uespLog.MsgType(uespLog.MSG_OTHER, "UESP: Found "..tostring(name).." ("..qualityMsg..")!")
	else
		uespLog.MsgType(uespLog.MSG_OTHER, "UESP: Found "..tostring(name).."!")
	end

	uespLog.lastLootTargetName = name
	uespLog.lastLootLockQuality = lockQuality
	
	uespLog.lastFoundTreasure.name = name
	uespLog.lastFoundTreasure.gameTime = GetGameTimeSeconds()
end


uespLog.lastFishHole = {
	gameTime = 0,
}

uespLog.FISHHOLE_MSG_MINGAMETIME = 10


function uespLog.OnFoundFish ()
	local logData = { }
	local gameTimeDiff = GetGameTimeSeconds() - uespLog.lastFishHole.gameTime
	
	logData.event = "Fish"
	
	uespLog.AppendDataToLog("all", logData, uespLog.GetCurrentTargetData(), uespLog.GetTimeData())
			
	if (gameTimeDiff <= uespLog.FISHHOLE_MSG_MINGAMETIME) then
		uespLog.lastFishHole.gameTime = GetGameTimeSeconds()
	else
		uespLog.lastFishHole.gameTime = GetGameTimeSeconds()
		uespLog.MsgColorType(uespLog.MSG_OTHER, uespLog.fishingColor, "Found fishing hole!")
	end
end


function uespLog.OnMailMessageReadable (eventCode, mailId)
	local senderDisplayName, senderCharacterName, subject, icon, unread, fromSystem, fromCustomerService, returned, numAttachments, attachedMoney, codAmount, expiresInDays, secsSinceReceived = GetMailItemInfo(mailId)
	
	uespLog.DebugExtraMsg("Read mail from " ..tostring(senderDisplayName).." with "..tostring(numAttachments).." items.")
	
	uespLog.lastMailItems = { }
	uespLog.lastMailId = mailId
	uespLog.lastMailGold = attachedMoney
	uespLog.lastMailCOD = codAmount
		
	for attachIndex = 1, numAttachments do
		local itemLink = GetAttachedItemLink(mailId, attachIndex)
		local icon, stack, creatorName = GetAttachedItemInfo(mailId, attachIndex) 
		
		local newItem = { }
		newItem.itemLink = itemLink
		newItem.stack = stack
		newItem.icon = icon
		
		uespLog.lastMailItems[attachIndex] = newItem
	end
	
	if (uespLog.GetAutoLootHirelingMails() and uespLog.IsHirelingMail(mailId)) then
		uespLog.AutolootHireMailNumAttempts = 0
		uespLog.AutolootHirelingMail(mailId)
	end
	
end


function uespLog.OnMailMessageTakeAttachedMoney (eventCode, mailId)
	local senderDisplayName, senderCharacterName, subject, icon, unread, fromSystem, fromCustomerService, returned, numAttachments, attachedMoney, codAmount, expiresInDays, secsSinceReceived = GetMailItemInfo(mailId)
	
	if (attachedMoney > 0) then
		uespLog.MsgColorType(uespLog.MSG_LOOT, uespLog.itemColor, "You received "..tostring(attachedMoney).." gold from mail attachment.")
	elseif (uespLog.lastMailGold > 0) then
		uespLog.MsgColorType(uespLog.MSG_LOOT, uespLog.itemColor, "You received "..tostring(uespLog.lastMailGold).." gold from mail attachment.")
	end
	
	if (uespLog.lastMailCOD > 0) then
		uespLog.MsgColorType(uespLog.MSG_LOOT, uespLog.itemColor, "You paid a mail COD charge of "..tostring(uespLog.lastMailGold).." gold to "..tostring(senderDisplayName)..".")
	end
	
	uespLog.lastMailGold = 0
	uespLog.lastMailCOD = 0
end


 function uespLog.GetHirelingLevel(tradeType)
	local hirelingLevel, craftLevel
	
	hirelingLevel = 0
	craftLevel = 0
	
	if (tradeType == CRAFTING_TYPE_ALCHEMY) then
		craftLevel = GetSkillAbilityUpgradeInfo(8, 1, 1)
	elseif (tradeType == CRAFTING_TYPE_BLACKSMITHING) then
		craftLevel = GetSkillAbilityUpgradeInfo(8, 2, 1)
		hirelingLevel = GetSkillAbilityUpgradeInfo(8, 2, 3)
	elseif (tradeType == CRAFTING_TYPE_ENCHANTING) then
		craftLevel = GetSkillAbilityUpgradeInfo(8, 4, 2)
		hirelingLevel = GetSkillAbilityUpgradeInfo(8, 4, 4)
	elseif (tradeType == CRAFTING_TYPE_CLOTHIER) then
		craftLevel = GetSkillAbilityUpgradeInfo(8, 3, 1)
		hirelingLevel = GetSkillAbilityUpgradeInfo(8, 3, 3)
	elseif (tradeType == CRAFTING_TYPE_PROVISIONING) then
		craftLevel = GetSkillAbilityUpgradeInfo(8, 5, 2)
		hirelingLevel = GetSkillAbilityUpgradeInfo(8, 5, 7)
	elseif (tradeType == CRAFTING_TYPE_WOODWORKING) then
		craftLevel = GetSkillAbilityUpgradeInfo(8, 6, 1)
		hirelingLevel = GetSkillAbilityUpgradeInfo(8, 6, 3)
	end
	
	return hirelingLevel, craftLevel
 end


function uespLog.OnMailMessageTakeAttachedItem (eventCode, mailId)
	local senderDisplayName, senderCharacterName, subject, icon, unread, fromSystem, fromCustomerService, returned, numAttachments, attachedMoney, codAmount, expiresInDays, secsSinceReceived = GetMailItemInfo(mailId)
	local tradeType = CRAFTING_TYPE_INVALID
	local logData = { }
	local timeData = uespLog.GetTimeData()
	
	uespLog.DebugExtraMsg("Received mail item from " ..tostring(senderDisplayName).." money="..tostring(attachedMoney))
	
	if (mailId ~= uespLog.lastMailId or #uespLog.lastMailItems == 0) then
		uespLog.DebugExtraMsg("Error: No attachments in mail")
		return
	end
	
	if (subject == "Getting Groceries" or subject == "Raw Provisioner Materials" or senderDisplayName == "Gavin Gavonne") then
		tradeType = CRAFTING_TYPE_PROVISIONING
	elseif (subject == "Raw Woodworker Materials" or senderDisplayName == "Pacrooti") then
		tradeType = CRAFTING_TYPE_WOODWORKING
	elseif (subject == "Raw Blacksmith Materials" or senderDisplayName == "Valinka Stoneheaver") then
		tradeType = CRAFTING_TYPE_BLACKSMITHING
	elseif (subject == "Raw Enchanter Materials" or senderDisplayName == "Abnab") then
		tradeType = CRAFTING_TYPE_ENCHANTING
	elseif (subject == "Raw Clothier Materials" or senderDisplayName == "UNKNOWN") then
		tradeType = CRAFTING_TYPE_CLOTHIER
	elseif (subject == "Raw Materials") then -- Unknown hireling message
		tradeType = 100
	else -- Not a tradeskill hireling message
		tradeType = CRAFTING_TYPE_INVALID
	end
	
	for attachIndex = 1, #uespLog.lastMailItems do
		--local itemLink = GetAttachedItemLink(mailId, attachIndex)
		--local icon, stack, creatorName = GetAttachedItemInfo(mailId, attachIndex) 
		local lastItem = uespLog.lastMailItems[attachIndex]
		
		logData = { }
		logData.event = "MailItem"
		logData.tradeType = tradeType
		logData.itemLink = uespLog.MakeNiceLink(lastItem.itemLink)
		logData.qnt = lastItem.stack
		logData.icon = lastItem.icon
		logData.sender = senderDisplayName
		logData.subject = subject
		logData.characterName = GetUnitName("player")
		logData.hirelingLevel, logData.craftLevel = uespLog.GetHirelingLevel(tradeType)
		
		uespLog.AppendDataToLog("all", logData, timeData)
		
		if (tradeType > 0) then
			uespLog.MsgColorType(uespLog.MSG_LOOT, uespLog.itemColor, "You received hireling mail item "..tostring(logData.itemLink).." (x"..tostring(lastItem.stack)..")")
		else
			uespLog.MsgColorType(uespLog.MSG_LOOT, uespLog.itemColor, "You received mail item "..tostring(logData.itemLink).." (x"..tostring(lastItem.stack)..")")
		end
		
		uespLog.TrackLoot(lastItem.itemLink, lastItem.stack)
	end
	
	if (#uespLog.lastMailItems > 0) then
		uespLog.TrackLootSource("mail")
	end
	
	uespLog.lastMailItems = { }
	uespLog.lastMailId = 0
end


 function uespLog.OnChatMessage (eventCode, messageType, fromName, chatText)
	--|HFFFFFF:item:45810:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|hJode|h"
	
	--uespLog.DebugExtraMsg("Chat Message "..tostring(messageType).." from "..tostring(fromName))
	
	local numLinks = 0
	
	for link in string.gmatch(chatText, "|H.-:item:.-|h.-|h") do
		numLinks = numLinks + 1
		
		local logData = uespLog.GetTimeData()
		logData.msgType = messageType
		uespLog.LogItemLink(link, "ItemLink", logData)
    end
	
	if (numLinks > 0) then
		uespLog.DebugExtraMsg("Logged "..tostring(numLinks).." item links from chat message.")
	end
	
 end


uespLog.menuUpdated = false
uespLog.PvpCheckCounter = 0
uespLog.PvpCheckCounterMax = 1000	-- Check roughly every 10 secs


function uespLog.OnUpdate ()

	uespLog.PvpCheckCounter = uespLog.PvpCheckCounter + 1
	
	if (uespLog.PvpCheckCounter >= uespLog.PvpCheckCounterMax) then
		uespLog.CheckForNewLocalBattles()
		uespLog.PvpCheckCounter = 0
	end

    if IsGameCameraUIModeActive() then
        return
    end
	
	local action, name, interactionBlocked, isOwned, additionalInfo, context, contextualLink, isCriminalInteract = GetGameCameraInteractableActionInfo()
	local active = IsPlayerInteractingWithObject()
	local interactionType = GetInteractionType()
	local x, y, z, zone
	
	if (interactionType ~= INTERACTION_HARVEST and uespLog.currentHarvestTarget ~= nil) then
		uespLog.DebugExtraMsg("Stopped harvesting "..tostring(uespLog.currentHarvestTarget.name)..":"..tostring(interactionType)..":"..tostring(action)..":"..tostring(name))
		uespLog.currentHarvestTarget = nil
	elseif (interactionType == INTERACTION_HARVEST and uespLog.currentHarvestTarget == nil) then
		uespLog.currentHarvestTarget = { }
		uespLog.currentHarvestTarget.x = uespLog.lastHarvestTarget.x
		uespLog.currentHarvestTarget.y = uespLog.lastHarvestTarget.y
		uespLog.currentHarvestTarget.zone = uespLog.lastHarvestTarget.zone
		uespLog.currentHarvestTarget.name = uespLog.lastHarvestTarget.name
		uespLog.currentHarvestTarget.harvestType = uespLog.lastHarvestTarget.harvestType
				
		uespLog.DebugExtraMsg("Started harvesting "..tostring(uespLog.currentHarvestTarget.name))
		
		--local targetName, targetType, targetActionName, targetIsOwned = GetLootTargetInfo()
		--uespLog.DebugMsg("Loot: "..tostring(targetName)..", "..tostring(targetType)..", "..tostring(targetActionName)..", "..tostring(targetIsOwned))
	end

    if (name == nil) then
		--if (uespLog.currentTargetData.name ~= "") then uespLog.DebugExtraMsg("CurrentTarget cleared") end
		uespLog.currentTargetData.name = ""
		uespLog.currentTargetData.x = ""
		uespLog.currentTargetData.y = ""
		uespLog.currentTargetData.zone = ""
		uespLog.currentTargetData.worldx = ""
		uespLog.currentTargetData.worldy = ""
		uespLog.currentTargetData.worldz = ""
		uespLog.currentTargetData.worldzoneid = ""
        return
    end
	
	if (not active) then
		
		--if (uespLog.lastTargetData.name ~= name) then
			--uespLog.DebugExtraMsg("Camera interactable changed to "..tostring(name))
		--end
		
		if (name ~= uespLog.lastActivateInfo.name) then
			uespLog.lastActivateInfo.name = ""
			uespLog.lastActivateInfo.gameTime = 0
			uespLog.lastLootTargetGameTime = 0
		end
		
		uespLog.lastTargetData.name = name
		uespLog.lastTargetData.x = uespLog.currentTargetData.x
		uespLog.lastTargetData.y = uespLog.currentTargetData.y
		uespLog.lastTargetData.zone = uespLog.currentTargetData.zone
		uespLog.lastTargetData.worldx = uespLog.currentTargetData.worldx
		uespLog.lastTargetData.worldy = uespLog.currentTargetData.worldy
		uespLog.lastTargetData.worldz = uespLog.currentTargetData.worldz
		uespLog.lastTargetData.worldzoneid = uespLog.currentTargetData.worldzoneid
		uespLog.lastTargetData.gameTime = GetGameTimeMilliseconds()
		uespLog.lastTargetData.timeStamp = GetTimeStamp()
		uespLog.lastTargetData.action = uespLog.currentTargetData.action
		uespLog.lastTargetData.interactionType = uespLog.currentTargetData.interactionType
    end
	
	if (interactionType == INTERACTION_NONE and action == uespLog.ACTION_COLLECT) then
		if (uespLog.lastHarvestTarget.name ~= uespLog.currentTargetData.name) then uespLog.DebugExtraMsg("Found collect node") end
		uespLog.lastHarvestTarget.x = uespLog.currentTargetData.x
		uespLog.lastHarvestTarget.y = uespLog.currentTargetData.y
		uespLog.lastHarvestTarget.zone = uespLog.currentTargetData.zone
		uespLog.lastHarvestTarget.name = uespLog.currentTargetData.name
		uespLog.lastHarvestTarget.harvestType = "collect"
	elseif (interactionType == INTERACTION_NONE and action == uespLog.ACTION_MINE) then
		if (uespLog.lastHarvestTarget.name ~= uespLog.currentTargetData.name) then uespLog.DebugExtraMsg("Found ore node") end
		uespLog.lastHarvestTarget.x = uespLog.currentTargetData.x
		uespLog.lastHarvestTarget.y = uespLog.currentTargetData.y
		uespLog.lastHarvestTarget.zone = uespLog.currentTargetData.zone
		uespLog.lastHarvestTarget.name = uespLog.currentTargetData.name
		uespLog.lastHarvestTarget.harvestType = "ore"
	elseif (interactionType == INTERACTION_NONE and action == uespLog.ACTION_CUT) then
		if (uespLog.lastHarvestTarget.name ~= uespLog.currentTargetData.name) then uespLog.DebugExtraMsg("Found wood node") end
		uespLog.lastHarvestTarget.x = uespLog.currentTargetData.x
		uespLog.lastHarvestTarget.y = uespLog.currentTargetData.y
		uespLog.lastHarvestTarget.zone = uespLog.currentTargetData.zone
		uespLog.lastHarvestTarget.name = uespLog.currentTargetData.name
		uespLog.lastHarvestTarget.harvestType = "wood"
	end

    if (action == nil or name == "" or name == uespLog.currentTargetData.name) then
        return
    end
		
	--uespLog.DebugMsg("Update: "..tostring(active)..", "..tostring(action))
	
	if (DoesUnitExist("reticleover")) then
		x, y, z, zone = uespLog.GetUnitPosition("reticleover")
		
		if (GetUnitRawWorldPosition ~= nil) then
			uespLog.currentTargetData.worldzoneid, uespLog.currentTargetData.worldx, uespLog.currentTargetData.worldy, uespLog.currentTargetData.worldz = GetUnitRawWorldPosition("player")
		end
		
		--uespLog.DebugMsg("UnitPos: "..tostring(x)..", "..tostring(y))
	else
		--local x1, y1 = uespLog.GetUnitPosition("reticleover")
		x, y, z, zone = uespLog.GetPlayerPosition()
		
		if (GetUnitRawWorldPosition ~= nil) then
			uespLog.currentTargetData.worldzoneid, uespLog.currentTargetData.worldx, uespLog.currentTargetData.worldy, uespLog.currentTargetData.worldz = GetUnitRawWorldPosition("player")
		end
		--uespLog.DebugMsg("PlayerPos: "..tostring(x)..", "..tostring(y))
		--uespLog.DebugMsg("UnitPos: "..tostring(x1)..", "..tostring(y1))
	end
	
	uespLog.currentTargetData.name = name
	uespLog.currentTargetData.x = x
	uespLog.currentTargetData.y = y
	uespLog.currentTargetData.zone = zone
	uespLog.currentTargetData.action = action
	uespLog.currentTargetData.interactionType = interactionType
	
	--uespLog.DebugExtraMsg("CurrentTarget = "..tostring(name))
	--uespLog.DebugExtraMsg("CurrentAction = "..tostring(action))
	--uespLog.DebugExtraMsg("interactionType = "..tostring(interactionType))
	
    if (interactionType == INTERACTION_NONE and action == uespLog.ACTION_USE) then

        if name == "Skyshard" then
			uespLog.OnFoundSkyshard()
        end

    elseif (interactionType == INTERACTION_NONE and action == uespLog.ACTION_UNLOCK) then
	
		if (name == "Chest") then
			uespLog.OnFoundTreasure("Chest", context)
		end
		
	elseif (interactionType == INTERACTION_NONE and action == uespLog.ACTION_STEALFROM) then
	
		if (name == "Safebox") then
			uespLog.OnFoundTreasure("Safebox", context)
		elseif (name == "Thieves Trove") then
			uespLog.OnFoundTreasure("Thieves Trove", context)
		end
		
	elseif (interactionType == INTERACTION_NONE and action == uespLog.ACTION_SEARCH) then
	
		if (name == "Heavy Sack") then
			uespLog.OnFoundTreasure("Heavy Sack")
		end		
	
    elseif (action == uespLog.ACTION_FISH) then
		uespLog.OnFoundFish()
    end

end


function uespLog.getDayOfMonth (yearDay)

	if yearDay < 30 then
		return yearDay + 1, 1
	elseif yearDay < 58 then
		return yearDay - 29, 2
	elseif yearDay < 89 then
		return yearDay - 57, 3
	elseif yearDay < 119 then
		return yearDay - 88, 4
	elseif yearDay < 150 then
		return yearDay - 118, 5
	elseif yearDay < 180 then
		return yearDay - 149, 6
	elseif yearDay < 211 then
		return yearDay - 179, 7
	elseif yearDay < 242 then
		return yearDay - 210, 8
	elseif yearDay < 272 then
		return yearDay - 241, 9
	elseif yearDay < 303 then
		return yearDay - 271, 10
	elseif yearDay < 333 then
		return yearDay - 302, 11
	else
		return yearDay - 333, 12
	end
	
end


function uespLog.getMoonPhaseStr(inputTimeStamp, includeDetails)
	local timeStamp = inputTimeStamp or GetTimeStamp()
	
	local moonOffsetTime = timeStamp - uespLog.DEFAULT_MOONPHASESTARTTIME
	local moonPhase = moonOffsetTime / uespLog.DEFAULT_MOONPHASETIME
	local moonPhaseNorm = moonPhase % 1
	local phaseStr = "Unknown"
	
	if (moonPhaseNorm <= 0.06) then
		phaseStr = "New"
	elseif (moonPhaseNorm <= 0.185) then
		phaseStr = "Waxing Crescent"
	elseif (moonPhaseNorm <= 0.31) then
		phaseStr = "First Quarter"
	elseif (moonPhaseNorm <= 0.435) then
		phaseStr = "Waxing Gibbous"
	elseif (moonPhaseNorm <= 0.56) then
		phaseStr = "Full"
	elseif (moonPhaseNorm <= 0.685) then
		phaseStr = "Waning Gibbous"
	elseif (moonPhaseNorm <= 0.81) then
		phaseStr = "Third Quarter"
	elseif (moonPhaseNorm <= 0.935) then
		phaseStr = "Waning Crescent"
	else
		phaseStr = "New"
	end	
	
	local result
	
	if (includeDetails) then
		result = string.format("%s (%0.2f)", phaseStr, moonPhase)
	else
		relMoonPhase = 100 - math.abs((moonPhase % 1)- 0.5)*200
		result = string.format("%s (%0.0f%% full)", phaseStr, relMoonPhase)
	end
	
	return result	
end


function uespLog.getGameTimeStr(inputTimestamp, includeDetails)
	local timeStamp = inputTimestamp or GetTimeStamp()

	local offsetTime = timeStamp - uespLog.DEFAULT_GAMETIME_OFFSET - uespLog.DEFAULT_GAMETIME_OFFSET_EXTRA
	
	local gameDayTime = offsetTime % uespLog.DEFAULT_REALSECONDSPERGAMEDAY
	local year = math.floor(offsetTime / uespLog.DEFAULT_REALSECONDSPERGAMEYEAR) + uespLog.DEFAULT_GAMETIME_YEAROFFSET
	local yearDay = math.floor((offsetTime % uespLog.DEFAULT_REALSECONDSPERGAMEYEAR) / uespLog.DEFAULT_REALSECONDSPERGAMEDAY)
	local day, month = uespLog.getDayOfMonth(yearDay)
	local weekDay = math.floor(((offsetTime / uespLog.DEFAULT_REALSECONDSPERGAMEDAY) + uespLog.GAMETIME_WEEKDAY_OFFSET) % 7) + 1
	local monthStr = uespLog.TES_MONTHS[month]
	local weekDayStr = uespLog.TES_WEEKS[weekDay]
	local hour = math.floor((gameDayTime / uespLog.DEFAULT_REALSECONDSPERGAMEHOUR) % 24)
	local minute = math.floor((gameDayTime / uespLog.DEFAULT_REALSECONDSPERGAMEMINUTE) % 60)
	local second = math.floor((gameDayTime / uespLog.DEFAULT_REALSECONDSPERGAMESECOND) % 60)
	
	local hourStr = string.format("%02d", hour)
	local minuteStr = string.format("%02d", minute)
	local secondStr = string.format("%02d", second)
	
	local TimeStr
	
		--"2E 582 Hearth's Fire, Morndas 08:12:11" 
	if (includeDetails) then
		TimeStr = "2E "..tostring(year).." "..monthStr.."("..tostring(month)..") "..tostring(day)..", "..weekDayStr.."("..tostring(weekDay).."), "..hourStr..":"..minuteStr..":"..secondStr
	else
		TimeStr = "2E "..tostring(year).." "..monthStr.." "..tostring(day)..", "..weekDayStr..", "..hourStr..":"..minuteStr..":"..secondStr
	end
		
	return TimeStr
end


function uespLog.ShowTime (inputTimestamp)
	local timeStamp = inputTimestamp or GetTimeStamp()
	local localGameTime = GetGameTimeMilliseconds()
	local timeStampStr = Id64ToString(timeStamp)
	local timeStampFmt = GetDateStringFromTimestamp(timeStamp)
	local version = _VERSION
	local apiVersion = GetAPIVersion()
	local gameTimeStr = uespLog.getGameTimeStr(timeStamp, uespLog.IsDebugExtra())
	local moonPhaseStr = uespLog.getMoonPhaseStr(timeStamp, uespLog.IsDebugExtra())
		
	uespLog.MsgColor(uespLog.timeColor, "UESP: Game Time = " .. gameTimeStr .. "")
	uespLog.MsgColor(uespLog.timeColor, "UESP: Moon Phase = " .. moonPhaseStr .. "")
	uespLog.MsgColor(uespLog.timeColor, "UESP: localGameTime = " .. tostring(localGameTime/1000) .. " sec")
	uespLog.MsgColor(uespLog.timeColor, "UESP: timeStamp = " .. tostring(timeStamp))
	uespLog.MsgColor(uespLog.timeColor, "UESP: timeStamp Date = " .. timeStampFmt)
	uespLog.MsgColor(uespLog.timeColor, "UESP: _VERSION = " ..version..",  API = "..tostring(apiVersion))	
	uespLog.DebugExtraMsg("UESP: timeStampStr = " .. timeStampStr)
end


function uespLog.ShowTreasureTimerHelp()
	uespLog.Msg("Expected one of the command formats:")
	uespLog.Msg(".      /uesptreasuretimer [on/off]")
	uespLog.Msg(".      /uesptreasuretimer [name] [duration]")
	uespLog.Msg(".      /uesptreasuretimer list")
		
	if (uespLog.IsTreasureTimerEnabled()) then
		uespLog.Msg("Treasure timer is currently enabled.")
	else
		uespLog.Msg("Treasure timer is currently disabled.")
	end
end


function uespLog.SetTreasureTimerDuration(name, duration)

	if (name == nil) then
		return
	end
	
	local safeName = string.lower(name)
	local currentDuration = uespLog.GetTreasureTimers()[safeName]

	if (currentDuration == nil) then
		uespLog.Msg("There is no treasure timer for "..tostring(name))
	elseif (duration == nil or duration == "") then
		uespLog.Msg("Treasure timer for "..tostring(name).." is "..tostring(currentDuration).." sec.")
		return
	else
		local newDuration = tonumber(duration)
		uespLog.GetTreasureTimers()[safeName] = newDuration
		uespLog.Msg("Set the treasure timer for "..tostring(name).." to "..tostring(newDuration).." sec.")
	end
	
end


SLASH_COMMANDS["/uesptreasuretimer"] = function (cmd)
	cmdWords = {}
	for word in cmd:gmatch("%S+") do table.insert(cmdWords, string.lower(word)) end
	
	if (#cmdWords < 1) then
		uespLog.ShowTreasureTimerHelp()
		return
	end
	
	firstCmd = cmdWords[1]
	
	if (firstCmd == "on") then
		uespLog.SetTreasureTimerEnabled(true)
		uespLog.Msg("Treasure timer is now enabled.")
	elseif (firstCmd == "off") then
		uespLog.SetTreasureTimerEnabled(false)
		uespLog.Msg("Treasure timer is now disabled.")
	elseif (firstCmd == "list" or firstCmd == "show") then
		uespLog.ShowTreasureTimers()
	elseif (firstCmd ~= "") then
	
		if (firstCmd == "heavy" or firstCmd == "thieves") then
			cmdWords[1] = cmdWords[1].." "..cmdWords[2]
			cmdWords[2] = cmdWords[3]
		end
		
		uespLog.SetTreasureTimerDuration(cmdWords[1], cmdWords[2])
	else
		uespLog.ShowTreasureTimerHelp()
	end
	
end


function uespLog.ShowTreasureTimers()
	local timers = uespLog.GetTreasureTimers()
	
	uespLog.Msg("Showing all treasure timer durations:")
	
	for name, timer in pairs(timers) do
		uespLog.Msg(".     "..tostring(name).." = "..tostring(timer).." sec")
	end
	
	timers = uespLog.CheckTreasureTimers()
		
	if (#timers == 0) then
		uespLog.Msg("No current treasure timers in progress!")
		return
	end
	
	uespLog.Msg("Showing current treasure timers in progress:")
	local timestamp = GetTimeStamp()
	
	for i, timer in pairs(timers) do
		local timeLeft = timer.endTime - timestamp
		uespLog.Msg(".     "..tostring(i)..") "..tostring(timer.name).." has "..tostring(timeLeft).." sec remaining")
	end
	
end


SLASH_COMMANDS["/uesptime"] = function (cmd)
	cmdWords = {}
	for word in cmd:gmatch("%S+") do table.insert(cmdWords, string.lower(word)) end
	
	if (#cmdWords < 1) then
		uespLog.ShowTime()
	elseif (cmdWords[1] == "cal" or cmdWords[1] == "calibrate") then
		local timeStamp = GetTimeStamp()
		local x, y, heading, zone = GetMapPlayerPosition("player")
		local headingStr = string.format("%.2f", heading*57.29582791)
		local cameraHeading = GetPlayerCameraHeading()
		local camHeadingStr = string.format("%.2f", cameraHeading*57.29582791)
		uespLog.MsgColor(uespLog.timeColor, "UESP: Current Time Stamp = " .. tostring(timeStamp).." secs")
		uespLog.MsgColor(uespLog.timeColor, "UESP: Player Heading = " .. tostring(headingStr).." degrees")
		uespLog.MsgColor(uespLog.timeColor, "UESP: Camera Heading = " .. tostring(camHeadingStr).." degrees")
		return
	elseif (cmdWords[1] == "daylength") then
	
		if (cmdWords[2] == nil) then
			uespLog.MsgColor(uespLog.timeColor, "UESP: Game time day length is currently "..tostring(uespLog.DEFAULT_REALSECONDSPERGAMEDAY).." secs")
			return
		end
		
		local value = tonumber(cmdWords[2])
		
		if (value > 0) then
			uespLog.DEFAULT_REALSECONDSPERGAMEDAY = value
			uespLog.MsgColor(uespLog.timeColor, "UESP: Game time day length set to "..tostring(uespLog.DEFAULT_REALSECONDSPERGAMEDAY).." secs")
		end
	else
		uespLog.ShowTime()
	end
	
end


SLASH_COMMANDS["/uespd"] = function(cmd)
	SLASH_COMMANDS["/script"]("d(".. tostring(cmd) .. ")")
end


SLASH_COMMANDS["/uespenl"] = function (cmd)
	local enl = GetEnlightenedPool()
	local mult = GetEnlightenedMultiplier()

	uespLog.MsgColor(uespLog.xpColor, "You have "..tostring(enl).." enlightenment at a x"..tostring(mult).." bonus.")
end


function uespLog.DisplayPowerStat (statType, statName)
	local currentStat, maxValue, effectiveMax = GetUnitPower("player", statType)
	uespLog.MsgColor(uespLog.statColor, "UESP: "..tostring(statName).." "..tostring(currentStat).." (effective max "..tostring(effectiveMax).." of ".. tostring(maxValue)..")")
end


function uespLog.DisplayStat (statType, statName)
	--value = GetPlayerStat(DerivedStats derivedStat, StatBonusOption statBonusOption, StatSoftCapOption statSoftCapOption)
	local currentStat = GetPlayerStat(statType, STAT_BONUS_OPTION_APPLY_BONUS, STAT_SOFT_CAP_OPTION_APPLY_SOFT_CAP)
	-- local noCapStat = GetPlayerStat(statType, STAT_BONUS_OPTION_APPLY_BONUS, STAT_SOFT_CAP_OPTION_DONT_APPLY_SOFT_CAP)
	
	uespLog.MsgColor(uespLog.statColor, "UESP: "..tostring(statName).." "..tostring(currentStat).." (no cap)")
end


SLASH_COMMANDS["/uespcharinfo"] = function (cmd)
	local numPoints = GetAvailableSkillPoints()
	local numSkyShards = GetNumSkyShards()
	
	uespLog.Msg("UESP: Skill Points = ".. tostring(numPoints))
	uespLog.Msg("UESP: Skyshards = ".. tostring(numSkyShards))
	
	local armorSC = GetPlayerStat(STAT_ARMOR_RATING, STAT_BONUS_OPTION_APPLY_BONUS, STAT_SOFT_CAP_OPTION_APPLY_SOFT_CAP)
	local hpSC = GetPlayerStat(STAT_HEALTH_MAX, STAT_BONUS_OPTION_APPLY_BONUS, STAT_SOFT_CAP_OPTION_APPLY_SOFT_CAP)
	local mgSC = GetPlayerStat(STAT_MAGICKA_MAX, STAT_BONUS_OPTION_APPLY_BONUS, STAT_SOFT_CAP_OPTION_APPLY_SOFT_CAP)
	
	local stSC = GetPlayerStat(STAT_MAGICKA_REGEN_COMBAT, STAT_BONUS_OPTION_APPLY_BONUS, STAT_SOFT_CAP_OPTION_APPLY_SOFT_CAP)
	
	uespLog.DisplayStat(STAT_HEALTH_MAX, "HP")
	uespLog.DisplayStat(STAT_MAGICKA_MAX, "Magicka")
	uespLog.DisplayStat(STAT_STAMINA_MAX, "Stamina")
	
	uespLog.DisplayStat(STAT_HEALTH_REGEN_COMBAT, "HP Combat Regen")
	uespLog.DisplayStat(STAT_MAGICKA_REGEN_COMBAT, "Magicka Combat Regen")
	uespLog.DisplayStat(STAT_STAMINA_REGEN_COMBAT, "Stamina Combat Regen")
	
	uespLog.DisplayStat(STAT_HEALTH_REGEN_IDLE, "HP Idle Regen")
	uespLog.DisplayStat(STAT_MAGICKA_REGEN_IDLE, "Magicka Idle Regen")
	uespLog.DisplayStat(STAT_STAMINA_REGEN_IDLE, "Stamina Idle Regen")
	
	uespLog.DisplayStat(STAT_ARMOR_RATING, "Armor")
	uespLog.DisplayStat(STAT_BLOCK, "Block")
	uespLog.DisplayStat(STAT_CRITICAL_RESISTANCE, "Critical Resist")
	uespLog.DisplayStat(STAT_SPELL_RESIST, "Spell Resist")
	uespLog.DisplayStat(STAT_MITIGATION, "Mitigation")
	uespLog.DisplayStat(STAT_SPELL_MITIGATION, "Spell Mitigation")
	uespLog.DisplayStat(STAT_DODGE, "Dodge")
	uespLog.DisplayStat(STAT_PARRY, "Parry")
	uespLog.DisplayStat(STAT_PHYSICAL_RESIST, "Physical Resist")
	
	uespLog.DisplayStat(STAT_DAMAGE_RESIST_COLD, "Resist Cold")
	uespLog.DisplayStat(STAT_DAMAGE_RESIST_DISEASE, "Resist Disease")
	uespLog.DisplayStat(STAT_DAMAGE_RESIST_DROWN, "Resist Drown")
	uespLog.DisplayStat(STAT_DAMAGE_RESIST_EARTH, "Resist Earth")
	uespLog.DisplayStat(STAT_DAMAGE_RESIST_FIRE, "Resist Fire")
	uespLog.DisplayStat(STAT_DAMAGE_RESIST_GENERIC, "Resist Generic")
	uespLog.DisplayStat(STAT_DAMAGE_RESIST_MAGIC, "Resist Magic")
	uespLog.DisplayStat(STAT_DAMAGE_RESIST_OBLIVION, "Resist Oblivion")
	uespLog.DisplayStat(STAT_DAMAGE_RESIST_PHYSICAL, "Resist Physical")
	uespLog.DisplayStat(STAT_DAMAGE_RESIST_POISON, "Resist Poison")
	uespLog.DisplayStat(STAT_DAMAGE_RESIST_SHOCK, "Resist Shock")
	uespLog.DisplayStat(STAT_DAMAGE_RESIST_START, "Resist Start")
		
	uespLog.DisplayStat(STAT_CRITICAL_STRIKE, "Critical Strike")
	uespLog.DisplayStat(STAT_WEAPON_AND_SPELL_DAMAGE, "Weapon Power")
	uespLog.DisplayStat(STAT_SPELL_POWER, "Spell Power")
	uespLog.DisplayStat(STAT_SPELL_CRITICAL, "Spell Critical")
	uespLog.DisplayStat(STAT_SPELL_PENETRATION, "Spell Penetration")
	uespLog.DisplayStat(STAT_POWER, "Power")
	uespLog.DisplayStat(STAT_ATTACK_POWER, "Attack Power")
	uespLog.DisplayStat(STAT_MISS, "Miss")
	uespLog.DisplayStat(STAT_PHYSICAL_PENETRATION, "Physical Penetration")
	
	uespLog.DisplayPowerStat(POWERTYPE_HEALTH, "HP")
	uespLog.DisplayPowerStat(POWERTYPE_MAGICKA, "Magicka")
	uespLog.DisplayPowerStat(POWERTYPE_STAMINA, "Stamina")
	uespLog.DisplayPowerStat(POWERTYPE_ULTIMATE, "Ultimate")
	uespLog.DisplayPowerStat(POWERTYPE_FINESSE, "Finesse")
	uespLog.DisplayPowerStat(POWERTYPE_WEREWOLF, "Werewolf")
	uespLog.DisplayPowerStat(POWERTYPE_MOUNT_STAMINA, "Mount Stamina")
	
	--uespLog.DisplayStat(STAT_CRITICAL_STRIKE, "")
	
	--uespLog.Msg("UESP: HP Soft Cap = ".. tostring(hpSC))
	--uespLog.Msg("UESP: MG Soft Cap = ".. tostring(mgSC))
	--uespLog.Msg("UESP: ST Soft Cap = ".. tostring(stSC))
	--uespLog.Msg("UESP: Armor Soft Cap = ".. tostring(armorSC))
end


function uespLog.LocateCommand(cmd)
	local Msg = "Position"
	local logData = { }
	local posData = uespLog.GetPlayerPositionData()
	local x, y, heading, zone = GetMapPlayerPosition("player")
		
	logData.event = "Location"
	
	if (cmd ~= "") then
		logData.label = cmd
		Msg = Msg .. "["..cmd.."]"
	end
	
	Msg = Msg .. string.format(" %.4f, %.4f, %s, heading %.1f deg", posData.x, posData.y, posData.zone, heading*57.29582791)
	--Msg = Msg .. " " .. tostring(posData.x) .. ", " .. tostring(posData.y) ..", " .. tostring(posData.zone) ..", heading "..tostring(heading)
	uespLog.Msg(Msg)
	
	uespLog.AppendDataToLog("all", logData, posData, uespLog.GetTimeData())
end


SLASH_COMMANDS["/uespdebug"] = function (cmd)

	if (cmd == "on") then
		uespLog.SetDebug(true)
		uespLog.SetDebugExtra(false)
		uespLog.Msg("Turned UESP debug log messages on.")
	elseif (cmd == "off") then
		uespLog.SetDebug(false)
		uespLog.SetDebugExtra(false)
		uespLog.Msg("Turned UESP debug log messages off.")
	elseif (cmd == "extra") then
		uespLog.SetDebug(true)
		uespLog.SetDebugExtra(true)
		uespLog.Msg("Turned UESP debug log messages to extra.")
	elseif (cmd == "") then
		local flagStr = uespLog.BoolToOnOff(uespLog.IsDebug())
		uespLog.Msg("Turns debug chat messages on/off. Command format is:")
		uespLog.Msg(".          /uespdebug [on||off||extra]")
		if (uespLog.IsDebugExtra()) then flagStr = "Extra" end
		uespLog.Msg("Debug output is currently " .. flagStr .. ".")
	end
	
end


SLASH_COMMANDS["/uesplog"] = function (cmd)

	if (cmd == "on") then
		uespLog.SetLogData(true)
		uespLog.Msg("Turned UESP data logging on.")
	elseif (cmd == "off") then
		uespLog.SetLogData(false)
		uespLog.Msg("Turned UESP data logging off.")
	elseif (cmd == "") then
		uespLog.Msg("UESP data logging is currently " .. uespLog.BoolToOnOff(uespLog.IsLogData()) .. ". Use 'on' or 'off' to set!")
	end
	
end


SLASH_COMMANDS["/uespmail"] = function (cmd)
	local cmds = { }
	local displayHelp = false
	
	for i in string.gmatch(cmd, "%S+") do cmds[#cmds + 1] = i end
	
	if (#cmds <= 0 or cmds[1] == "help") then
		displayHelp = true
	elseif (cmds[1] == "deletenotify") then
		if (cmds[2] == "on") then
			uespLog.SetMailDeleteNotify(true)
			uespLog.Msg("Turned UESP delete mail notify on.")
		elseif (cmds[2] == "off") then
			uespLog.SetMailDeleteNotify(false)
			uespLog.Msg("Turned UESP delete mail notify off.")
		elseif (cmds[2] == "" or cmds[2] == nil) then
			uespLog.Msg("UESP delete mail notification is currently " .. uespLog.BoolToOnOff(uespLog.IsMailDeleteNotify()) .. ". Use 'on' or 'off' to set!")
		else
			displayHelp = true
		end
	else
		displayHelp = true
	end
	
	if (displayHelp) then
		uespLog.Msg("Turns the mail delete confirmation on/off. Command format is:")
		uespLog.Msg(".      /uespmail deletenotify [on||off]")
	end
	
end


SLASH_COMMANDS["/uespcolor"] = function (cmd)

	if (cmd == "on") then
		uespLog.SetColor(true)
		uespLog.Msg("Turned UESP color output on.")
	elseif (cmd == "off") then
		uespLog.SetColor(false)
		uespLog.Msg("Turned UESP color output off.")
	elseif (cmd == "") then
		uespLog.Msg("UESP color output is currently " .. uespLog.BoolToOnOff(uespLog.IsColor()) .. ". Use 'on' or 'off' to set!")
	end
	
end


SLASH_COMMANDS["/uespdump"] = function(cmd)
	local helpString = "Use one of: recipes, skills, achievements, inventory, globals, cp"
	local cmds, firstCmd = uespLog.SplitCommands(cmd)
	
	if (not uespLog.IsLogData()) then
		uespLog.MsgColor(uespLog.mineColorWarning, "WARNING -- Logging is currently disabled. Enable with '/uesplog on'.")
	end

	if (#cmds <= 0) then
		uespLog.Msg(helpString)
	elseif (firstCmd == "recipes") then
		uespLog.DumpRecipes()
	elseif (firstCmd == "skills") then
		uespLog.DumpSkills(cmds[2], cmds[3])
	elseif (firstCmd == "achievements") then
		uespLog.DumpAchievements(cmds[2])
	elseif (firstCmd == "inventory") then
		uespLog.DumpInventory()
	elseif (firstCmd == "cp" or firstCmd == "championpoints") then
		uespLog.DumpChampionPoints2(cmds[2])
	elseif (firstCmd == "globals") then
		
		if (cmds[2] == "end" or cmds[2] == "stop") then
			uespLog.DumpGlobalsIterateEnd()
		elseif (cmds[2] == "begin" or cmds[2] == "start") then
			uespLog.DumpGlobalsIterateStart(tonumber(cmds[3]))
		elseif (not uespLog.dumpIterateEnabled) then
			uespLog.DumpGlobals(tonumber(cmds[2]))
		else
			uespLog.Msg("Dump globals iterative currently running...")
		end
	
	elseif (firstCmd == "globalprefix") then
		local l1, l2, l3 = globalprefixes()
		uespLog.DumpGlobals(tonumber(cmds[2]), l2)
	elseif (firstCmd == "smith") then
		uespLog.DumpSmithItems(false)
	elseif (firstCmd == "smithset") then
		uespLog.DumpSmithItems(true)
	elseif (firstCmd == "tooltip") then
		uespLog.DumpToolTip()
	else
		uespLog.Msg(helpString)
	end
	
end


function uespLog.DumpSkills(opt1, opt2)

	if (opt2 == nil) then opt2 = "" end

	if (opt1 == nil or opt1 == "" or opt1 == "basic") then
		return uespLog.DumpSkillsBasic()
	elseif (opt1 == "progression") then
		uespLog.DumpSkillsProgression(opt2)
		return true
	elseif (opt1 == "learned") then
		uespLog.DumpLearnedAbilities(opt2)
		return true
	elseif (opt1 == "types") then
		uespLog.DumpSkillTypes(opt2)
		return true
	elseif (opt1 == "all") then
		uespLog.DumpSkillsStart(opt2)
		uespLog.DumpSkillTypes(opt2)
		uespLog.DumpSkillsProgression(opt2)
		uespLog.DumpLearnedAbilities(opt2)
		uespLog.DumpSkillMissing(opt2)
		return true
	elseif (opt1 == "abilities") then
		uespLog.DumpSkillsStart(opt2)
		return true
	elseif (opt1 == "char" or opt1 == "character") then
		uespLog.DumpSkillTypes(opt2)
		uespLog.DumpSkillsProgression(opt2)
		uespLog.DumpLearnedAbilities(opt2)
		uespLog.DumpSkillMissing(opt2)
		return true
	elseif (opt1 == "class") then
		uespLog.DumpSkillTypes(opt2, true)
		uespLog.DumpSkillsProgression(opt2, true)
		uespLog.DumpLearnedAbilities(opt2)
		return true
	elseif (opt1 == "race") then
		uespLog.DumpSkillTypes(opt2, false, true)
		uespLog.DumpLearnedAbilities(opt2)
		return true
	elseif (opt1 == "passive" or opt1 == "passives") then
		uespLog.DumpSkillTypes(opt2, false, false, true)
		return true
	elseif (opt1 == "missing") then
		uespLog.DumpSkillMissing(opt2)
		return true
	else
		uespLog.Msg("Expected format:")
		uespLog.Msg(".     /uespdump skills [type] [note]")
		uespLog.Msg(".     [type] is one of basic, progression, abilities, character, race, class, learned, types, all, missing")
	end
	
	return false
end


function uespLog.DumpSkillMissing(note)
	local count = 0
	local logData = {}
	local lastAbilityIndex = -1
	
	uespLog.Msg("Dumping skills in currently defined missing skill data...")
	
	logData.event = "skillDump::StartMissing"
	logData.apiVersion = GetAPIVersion()
	logData.note = note
	uespLog.AppendDataToLog("all", logData, uespLog.GetTimeData())

	for k, skillData in ipairs(uespLog.MISSING_SKILL_DATA) do
		local abilityIndex = skillData[1]
		local rank = skillData[2]
		local abilityId = skillData[3]
		local learnedLevel = skillData[4]
		local skillLine = skillData[5]
		local abilityType = skillData[6]
		local skillType = skillData[7]
		local extraData = {	}
		
		local lastAbility = nil
		local nextAbility = nil
		local nextAbility2 = nil
		
		if (abilityType == 1) then
			lastAbility = uespLog.MISSING_SKILL_DATA[k-1]
			if (rank == 1) then lastAbility = nil end
			
			nextAbility = uespLog.MISSING_SKILL_DATA[k+1]
			
			if (nextAbility ~= nil and nextAbility[2] <= rank) then
				nextAbility = nil
			end
		else
			lastAbility = uespLog.MISSING_SKILL_DATA[k-1]
			if (rank == 1) then lastAbility = nil end
			
			nextAbility = uespLog.MISSING_SKILL_DATA[k+1]
			
			if (rank == 9) then
				lastAbility = uespLog.MISSING_SKILL_DATA[k-5]
			elseif (rank == 4) then
				nextAbility2 = uespLog.MISSING_SKILL_DATA[k+5]
			elseif (rank == 8 or rank == 12) then
				nextAbility = nil
			end
			
			if (nextAbility ~= nil and nextAbility[2] <= rank) then
				nextAbility = nil
			end
		
		end		
		
		extraData.rank = rank
		extraData.learnedLevel = learnedLevel
		extraData.skillLine = skillLine
		extraData.abilityIndex = abilityIndex
		extraData.passive = false
		extraData.ultimate = false
		extraData.prevSkill = 0
		extraData.nextSkill = 0
		extraData.nextSkill2 = 0
		extraData.skillType = skillType
		
		if (lastAbility ~= nil) then
			extraData.prevSkill = lastAbility[3]
		end
		
		if (nextAbility ~= nil) then
			extraData.nextSkill = nextAbility[3]
		end
		
		if (nextAbility2 ~= nil) then
			extraData.nextSkill2 = nextAbility2[3]
		end
		
		if (abilityType == 1) then
			extraData.passive = true
		elseif (abilityType == 2) then
			extraData.ultimate = true
		end
		
		uespLog.DumpSkill(abilityId, extraData)
		
		count = count + 1
		lastAbilityIndex = abilityIndex
	end
	
	logData = {}
	logData.event = "skillDump::EndMissing"
	uespLog.AppendDataToLog("all", logData)
	
	uespLog.Msg("Found and dumped "..count.." missing skills!")
end


function uespLog.GetSkillTypeName(skillType)
	return GetString(SI_SKILLTYPE1 + skillType - 1)
end


function uespLog.DumpSkillTypes(note, classOnly, raceOnly, passiveOnly)
	local logData = { }
	local count = 0
	local numSkillTypes = GetNumSkillTypes()
	local skillType
	local skillIndex
	local abilityIndex
	local count = 0
	local startSkill = 1
	local endSkill = numSkillTypes
	local skillLineCount = 0
	
	classOnly = classOnly or false
	raceOnly = raceOnly or false
	passiveOnly = passiveOnly or false
	uespLog.Msg("Logging abilities by skill types for current character...")
	
	if (classOnly) then
		startSkill = 1
		
		if (raceOnly) then
			endSkill = 7
			uespLog.Msg(".     Logging only class and race abilities...")
		else
			endSkill = 1
			uespLog.Msg(".     Logging only class abilities...")
		end
	elseif (raceOnly) then
		startSkill = 7
		endSkill = 7
		uespLog.Msg(".     Logging only race abilities...")
	end
	
	if (passiveOnly) then
		uespLog.Msg(".     Logging only passive abilities...")
	end
	
	logData.event = "skillDump::StartType"
	logData.apiVersion = GetAPIVersion()
	logData.note = note
	logData.classOnly = classOnly
	uespLog.AppendDataToLog("all", logData, uespLog.GetTimeData())
	
	for skillType = startSkill, endSkill do
	
		if (skillType > 1 and classOnly and raceOnly) then
			skillType = 7
		end
			
		local numSkillLines = GetNumSkillLines(skillType)
		local skillTypeName = uespLog.GetSkillTypeName(skillType)
		
		logData = { }
		logData.event = "skillType"
		logData.class = GetUnitClass("player")
		logData.race = GetUnitRace("player")
		logData.classId = GetUnitClassId("player")
		logData.skillType = skillType
		logData.skillName = skillTypeName
		logData.numSkillLines = numSkillLines
		
		uespLog.AppendDataToLog("all", logData)
		
		for skillIndex = 1, numSkillLines do
			local numSkillAbilities = GetNumSkillAbilities(skillType, skillIndex)
			
			skillLineCount = skillLineCount + 1
			
			logData = { }
			logData.event = "skillLine"
			logData.skillType = skillType
			logData.skillName = skillTypeName
			
			if (skillType == 1) then
				logData.class = GetUnitClass("player")
			elseif (skillType == 7) then
				logData.race = GetUnitRace("player")
			end
			
			logData.xpString = "0"
			logData.numRanks = 1
			logData.totalXp = 0
			local lastRankXP = 0
		
			for i = 1, 70 do
				local startXP, nextRankStartXP = GetSkillLineRankXPExtents(skillType, skillIndex, i)
				
				if (startXP == nil or nextRankStartXP == nil) then 
					break
				end
				
				logData.xpString = logData.xpString .. "," .. tostring(nextRankStartXP - lastRankXP)
				logData.numRanks = logData.numRanks + 1
				logData.totalXp = nextRankStartXP
				lastRankXP = nextRankStartXP
			end
			
			logData.skillIndex = skillIndex
			logData.numAbilities = numSkillAbilities
			logData.name, _, _, logData.skillLineId = GetSkillLineInfo(skillType, skillIndex)
			uespLog.AppendDataToLog("all", logData)
			
					-- Not needed since update 18
			numSkillAbilities = 0
			
			for abilityIndex = 1, numSkillAbilities do
				local progressionIndex
								
				logData = { }
				logData.event = "skillAbility"
				logData.skillType = skillType
				
				if (skillType == 1) then
					logData.class = GetUnitClass("player")
				elseif (skillType == 7) then
					logData.race = GetUnitRace("player")
				end
				
				logData.skillIndex = skillIndex
				logData.abilityIndex = abilityIndex
				logData.name, logData.texture, logData.rank, logData.passive, logData.ultimate, logData.purchase, progressionIndex = GetSkillAbilityInfo(skillType, skillIndex, abilityIndex)
				logData.abilityId1 = GetSkillAbilityId(skillType, skillIndex, abilityIndex, false)
				logData.abilityId2 = GetSkillAbilityId(skillType, skillIndex, abilityIndex, true)
				logData.level, logData.maxLevel = GetSkillAbilityUpgradeInfo(skillType, skillIndex, abilityIndex)
				
				local _, _, nextEarnedRank = GetSkillAbilityNextUpgradeInfo(skillType, skillIndex, abilityIndex)
				
				if (nextEarnedRank ~= nil) then
					logData.nextEarnedRank = nextEarnedRank
				end
				
				if (progressionIndex ~= nil) then
					local name, morph, rank = GetAbilityProgressionInfo(progressionIndex)
					logData.level = rank
					logData.maxLevel = 4
				end
				
				if (logData.passive) then
					if (logData.level == nil) then 
						if (logData.purchase) then
							logData.level = 1
						else
							logData.level = 0 
						end
					end
					if (logData.maxLevel == nil) then logData.maxLevel = 1 end				
				else
					if (logData.level == nil) then logData.level = -1 end
					if (logData.maxLevel == nil) then logData.maxLevel = -1 end				
				end
				
				if (not passiveOnly or (logData.passive and passiveOnly)) then
					uespLog.AppendDataToLog("all", logData)
					count = count + 1
				end
				
			end
		end
		
		if (classOnly) then
			if (raceOnly) then
				numSkillTypes = 1
				uespLog.Msg(".     Logging only class abilities...")
			end
		end
	end
	
	--uespLog.Msg(".     Found "..tostring(count).." abilities by type!")
	uespLog.Msg(".     Found "..tostring(skillLineCount).." skill Lines!")
	
	logData = { }
	logData.event = "skillDump::EndType"
	logData.count = count
	uespLog.AppendDataToLog("all", logData, uespLog.GetTimeData())
end


function uespLog.DumpLearnedAbilities(note)
	local logData = { }
	local count = 0
	local level = 0
	
	uespLog.Msg("Logging learned abilities...")
	
	logData.event = "skillDump::StartLearned"
	logData.apiVersion = GetAPIVersion()
	logData.note = note
	uespLog.AppendDataToLog("all", logData, uespLog.GetTimeData())
	
	for level = 0, 70 do
		local learnedIndex
		local numLearned = GetNumAbilitiesLearnedForLevel(level, false)
		
		for learnedIndex = 1, numLearned do
			logData = { }
			
			logData.event = "skillLearned"
			logData.progress = 0
			logData.level = level
			logData.name, logData.texture, logData.abilityIndex, logData.progressionIndex = GetLearnedAbilityInfoForLevel(level, learnedIndex, false)
			logData.id = GetAbilityIdByIndex(logData.abilityIndex)
			uespLog.AppendDataToLog("all", logData)
			
			count = count + 1
		end
	end

	uespLog.Msg(".     Found "..tostring(count).." learned abilities!")
	
	logData = { }
	logData.event = "skillDump::EndLearned"
	logData.count = count
	uespLog.AppendDataToLog("all", logData, uespLog.GetTimeData())
end


function uespLog.DumpSkillsProgression(note, classOnly)
	local logData = { }
	local progressionIndex = 0
	local count = 0
	
	uespLog.Msg("Logging skill progressions...")
	
		-- Doesn't work as GetSkillAbilityIndicesFromProgressionIndex() doesn't seem to work correctly
	classOnly = classOnly or false
	
	logData.event = "skillDump::StartProgression"
	logData.apiVersion = GetAPIVersion()
	logData.note = note
	uespLog.AppendDataToLog("all", logData, uespLog.GetTimeData())

	for progressionIndex = 1, 300 do
		local name, morph, rank = GetAbilityProgressionInfo(progressionIndex)
		
		if (name ~= "" and morph >= 0 and rank >= 0) then
			logData = { }
			logData.event = "skillProgression"
			logData.name = name
			logData.index = progressionIndex
			
				-- NOTE: The abilityIndex# returned by this function doesn't appear to be correct
			logData.name0, logData.texture0, logData.abilityIndex0 = GetAbilityProgressionAbilityInfo(progressionIndex, 0, 1)
			logData.name1, logData.texture1, logData.abilityIndex1 = GetAbilityProgressionAbilityInfo(progressionIndex, 1, 1)
			logData.name2, logData.texture2, logData.abilityIndex2 = GetAbilityProgressionAbilityInfo(progressionIndex, 2, 1)
			
				-- NOTE: This function doesn't seem to return the correct values
			logData.skillType, logData.skillIndex, logData.abilityIndex = GetSkillAbilityIndicesFromProgressionIndex(progressionIndex)
			
			logData.id01 = GetAbilityProgressionAbilityId(progressionIndex, 0, 1)
			logData.id02 = GetAbilityProgressionAbilityId(progressionIndex, 0, 2)
			logData.id03 = GetAbilityProgressionAbilityId(progressionIndex, 0, 3)
			logData.id04 = GetAbilityProgressionAbilityId(progressionIndex, 0, 4)
			logData.id11 = GetAbilityProgressionAbilityId(progressionIndex, 1, 1)
			logData.id12 = GetAbilityProgressionAbilityId(progressionIndex, 1, 2)
			logData.id13 = GetAbilityProgressionAbilityId(progressionIndex, 1, 3)
			logData.id14 = GetAbilityProgressionAbilityId(progressionIndex, 1, 4)
			logData.id21 = GetAbilityProgressionAbilityId(progressionIndex, 2, 1)
			logData.id22 = GetAbilityProgressionAbilityId(progressionIndex, 2, 2)
			logData.id23 = GetAbilityProgressionAbilityId(progressionIndex, 2, 3)
			logData.id24 = GetAbilityProgressionAbilityId(progressionIndex, 2, 4)
			
			uespLog.AppendDataToLog("all", logData)
			count = count + 1
		end
	end
	
	uespLog.Msg(".     Found "..tostring(count).." skill progressions!")
	
	logData = { }
	logData.event = "skillDump::EndProgression"
	logData.count = count
	uespLog.AppendDataToLog("all", logData, uespLog.GetTimeData())	
end


uespLog.SkillDump_validAbilityCount = 0
uespLog.SkillDump_startAbilityId = 0
uespLog.SkillDump_countAbilityId = 5000
uespLog.SkillDump_lastAbilityId = 200000
uespLog.SkillDump_lastValidAbilityId = 0
uespLog.SkillDump_delay = 2000


function uespLog.DumpSkillsStart(note)
	local abilityId
	local logData = { }
	
	logData.event = "skillDump::Start"
	logData.apiVersion = GetAPIVersion()
	logData.note = note
	uespLog.AppendDataToLog("all", logData, uespLog.GetTimeData())
	
	uespLog.Msg("Logging all skills with note '"..tostring(note).."'...")
	
	uespLog.SkillDump_validAbilityCount = 0
	uespLog.SkillDump_startAbilityId = 1
	uespLog.SkillDump_lastValidAbilityId = 0

	uespLog.DumpSkillsStart_DoNext()
	
	return true
end


function uespLog.DumpSkillsStart_DoNext()
	local endId = uespLog.SkillDump_startAbilityId + uespLog.SkillDump_countAbilityId
	
	uespLog.Msg("Logging skills between "..tostring(uespLog.SkillDump_startAbilityId).." to "..tostring(endId).."...")

	for abilityId = uespLog.SkillDump_startAbilityId, endId do
	
		if (DoesAbilityExist(abilityId)) then
			uespLog.SkillDump_validAbilityCount = uespLog.SkillDump_validAbilityCount + 1
			uespLog.SkillDump_lastValidAbilityId = abilityId
			uespLog.DumpSkill(abilityId)
		end
		
	end

	uespLog.SkillDump_startAbilityId = endId + 1
	
	if (uespLog.SkillDump_startAbilityId >= uespLog.SkillDump_lastAbilityId) then
		return uespLog.DumpSkillsEnd()
	end
	
	zo_callLater(uespLog.DumpSkillsStart_DoNext, uespLog.SkillDump_delay)
	
	return true
end


function uespLog.DumpSkillsEnd()
	local logData = { }
	
	uespLog.Msg("Found "..tostring(uespLog.SkillDump_validAbilityCount).." abilities...")
	uespLog.Msg("Last valid ability ID is "..tostring(uespLog.SkillDump_lastValidAbilityId)..".")
	
	uespLog.SkillDump_startAbilityId =  uespLog.SkillDump_lastAbilityId

	logData.event = "skillDump::End"
	logData.abilityCount = validAbilityCount
	uespLog.AppendDataToLog("all", logData, uespLog.GetTimeData())
	return true
end


function uespLog.DumpSkill(abilityId, extraData)
	local name = GetAbilityName(abilityId)
	local isPassive = IsAbilityPassive(abilityId)
	local channeled, castTime, channelTime = GetAbilityCastInfo(abilityId)
	local targetDesc = GetAbilityTargetDescription(abilityId)
	local minRange, maxRange = GetAbilityRange(abilityId)
	local radius = GetAbilityRadius(abilityId)
	local angleDistance = GetAbilityAngleDistance(abilityId)
	local duration = GetAbilityDuration(abilityId)
	local cost, mechanic = GetAbilityCost(abilityId)
	local descHeader = tostring(GetAbilityDescriptionHeader(abilityId))
	local description = GetAbilityDescription(abilityId)
	local upgradeLines = uespLog.FormatSkillUpgradeLines(GetAbilityUpgradeLines(abilityId))
	local effectLines = uespLog.FormatSkillEffectLines(GetAbilityNewEffectLines(abilityId))
	local isToggle = IsAbilityDurationToggled(abilityId)
	local costTime, mechanicTime, chargeFreqMS = GetAbilityCostOverTime(abilityId)
	local logData = { }
		
	extraData = extraData or {}
	
	if (GetAbilityBuffType ~= nil) then
		logData.buffType = GetAbilityBuffType(abilityId)
	end
	
	logData.event = "skill"
	logData.id = abilityId
	logData.name = name
	logData.passive = isPassive
	logData.channel = channeled
	logData.castTime = castTime
	logData.channelTime = channelTime
	logData.target = targetDesc
	logData.minRange = minRange
	logData.maxRange = maxRange
	logData.radius = radius
	logData.angleDistance = angleDistance
	logData.duration = duration
	logData.cost = cost
	logData.isToggle = isToggle
	logData.costTime = costTime
	logData.mechanicTime = mechanicTime
	logData.chargeFreqMS = chargeFreqMS
	logData.mechanic = mechanic
	logData.icon = GetAbilityIcon(abilityId)
	logData.perm = IsAbilityPermanent(abilityId)
	
	logData.skillType, logData.skillIndex, logData.abilityIndex, logData.morph, logData.tempRank = GetSpecificSkillAbilityKeysByAbilityId(abilityId)
	
	if (logData.skillType <= 0 or uespLog.EndsWith(name, "Dummy")) then
		logData.skillType = nil
		logData.skillIndex = nil
		logData.abilityIndex = nil
		logData.morph = nil
		logData.rank = nil
	else
		_, _, logData.earnedLevel, _, logData.ultimate, _, progressionIndex, _ = GetSkillAbilityInfo(logData.skillType, logData.skillIndex, logData.abilityIndex)
		
		logData.skillLineName, _, _, logData.skillLineId = GetSkillLineInfo(logData.skillType, logData.skillIndex)
		logData.currentLevel, logData.maxLevel = GetSkillAbilityUpgradeInfo(logData.skillType, logData.skillIndex, logData.abilityIndex)
		
		if (isPassive and logData.maxLevel) then
		
			for i = 1, logData.maxLevel do
				logData["passive" .. tostring(i)], logData["rank" .. tostring(i)] = GetSpecificSkillAbilityInfo(logData.skillType, logData.skillIndex, logData.abilityIndex, 1, i)
			end
			
		elseif (isPassive) then
			logData.maxLevel = 1
			logData.passive1 = abilityId
			logData.rank1 = logData.earnedLevel
		else
			logData.id1 = GetSpecificSkillAbilityInfo(logData.skillType, logData.skillIndex, logData.abilityIndex, 0, 1)
			logData.id2 = GetSpecificSkillAbilityInfo(logData.skillType, logData.skillIndex, logData.abilityIndex, 1, 1)
			logData.id3 = GetSpecificSkillAbilityInfo(logData.skillType, logData.skillIndex, logData.abilityIndex, 2, 1)
		end
			
				-- Only works for skills the character can learn
		if (progressionIndex) then
			--logData.id1 = GetAbilityProgressionAbilityId(progressionIndex, 0, 1)
			--logData.id2 = GetAbilityProgressionAbilityId(progressionIndex, 1, 1)
			--logData.id3 = GetAbilityProgressionAbilityId(progressionIndex, 2, 1)
		end
	end
	
	-- GetAbilityProgressionRankFromAbilityId(number abilityId) Returns: number:nilable rank
	-- GetAbilityProgressionXPInfoFromAbilityId(number abilityId) Returns: boolean hasProgression, number progressionIndex, number lastRankXp, number nextRankXP, number currentXP, boolean atMorph
	
	logData.desc1 = tostring(GetAbilityDescription(abilityId, 1))
	logData.desc2 = tostring(GetAbilityDescription(abilityId, 2))
	logData.desc3 = tostring(GetAbilityDescription(abilityId, 3))
	logData.desc4 = tostring(GetAbilityDescription(abilityId, 4))
	
	if (descHeader ~= "") then
		logData.desc = "|cffffff" .. descHeader .."|r\n".. tostring(description)
		logData.desc1 = "|cffffff" .. descHeader .."|r\n".. tostring(logData.desc1)
		logData.desc2 = "|cffffff" .. descHeader .."|r\n".. tostring(logData.desc2)
		logData.desc3 = "|cffffff" .. descHeader .."|r\n".. tostring(logData.desc3)
		logData.desc4 = "|cffffff" .. descHeader .."|r\n".. tostring(logData.desc4)
	else
		logData.desc = tostring(description)
	end
	
	if (upgradeLines and upgradeLines ~= "") then logData.upgradeLines = upgradeLines end
	if (effectLines and effectLines ~= "") then logData.effectLines = effectLines end
	
	local rankData = uespLog.BASESKILL_RANKDATA[abilityId]
	
	if ((logData.skillType ~= nil or rankData ~= nil) and not isPassive) then
		logData.cost1 = GetAbilityCost(abilityId, 1)
		logData.cost2 = GetAbilityCost(abilityId, 2)
		logData.cost3 = GetAbilityCost(abilityId, 3)
		logData.cost4 = GetAbilityCost(abilityId, 4)
		
		logData.duration1 = GetAbilityDuration(abilityId, 1)
		logData.duration2 = GetAbilityDuration(abilityId, 2)
		logData.duration3 = GetAbilityDuration(abilityId, 3)
		logData.duration4 = GetAbilityDuration(abilityId, 4)
		
		logData.channel1, logData.castTime1, logData.channelTime1 = GetAbilityCastInfo(abilityId, 1)
		logData.channel2, logData.castTime2, logData.channelTime2 = GetAbilityCastInfo(abilityId, 2)
		logData.channel3, logData.castTime3, logData.channelTime3 = GetAbilityCastInfo(abilityId, 3)
		logData.channel4, logData.castTime4, logData.channelTime4 = GetAbilityCastInfo(abilityId, 4)
		
		logData.minRange1, logData.maxRange1 = GetAbilityRange(abilityId, 1)
		logData.minRange2, logData.maxRange2 = GetAbilityRange(abilityId, 2)
		logData.minRange3, logData.maxRange3 = GetAbilityRange(abilityId, 3)
		logData.minRange4, logData.maxRange4 = GetAbilityRange(abilityId, 4)
		
		logData.radius1 = GetAbilityRadius(abilityId, 1)
		logData.radius2 = GetAbilityRadius(abilityId, 2)
		logData.radius3 = GetAbilityRadius(abilityId, 3)
		logData.radius4 = GetAbilityRadius(abilityId, 4)
		
		logData.target1 = tostring(GetAbilityTargetDescription(abilityId, 1))
		logData.target2 = tostring(GetAbilityTargetDescription(abilityId, 2))
		logData.target3 = tostring(GetAbilityTargetDescription(abilityId, 3))
		logData.target4 = tostring(GetAbilityTargetDescription(abilityId, 4))
		
		logData.costTime1, logData.mechanicTime1, logData.chargeFreqMS1 = GetAbilityCostOverTime(abilityId, 1)
		logData.costTime2, logData.mechanicTime2, logData.chargeFreqMS2 = GetAbilityCostOverTime(abilityId, 2)
		logData.costTime3, logData.mechanicTime3, logData.chargeFreqMS3 = GetAbilityCostOverTime(abilityId, 3)
		logData.costTime4, logData.mechanicTime4, logData.chargeFreqMS4 = GetAbilityCostOverTime(abilityId, 4)
	else
		logData.desc1 = nil
		logData.desc2 = nil
		logData.desc3 = nil
		logData.desc4 = nil
	end
	
	uespLog.AppendDataToLog("all", logData, extraData)
end


function uespLog.FormatSkillUpgradeLines(...)
	local output = ""
	
    local numUpgradeReturns = select("#", ...)
	
    if (numUpgradeReturns > 0) then
	
        for i = 1, numUpgradeReturns, 3 do
            local label, oldValue, newValue = select(i, ...)
            if (i > 1) then output = output .. ", " end
			output = output .. tostring(label) .."::"..tostring(oldValue).."::"..tostring(newValue)
        end
		
    end
	
	return output
end


function uespLog.FormatSkillEffectLines(...)
	local output = ""
	
    local numEffectLines = select("#", ...)
	
    if (numEffectLines > 0) then
	
        for i = 1, numEffectLines do
            local newEffect = select(i, ...)
            if (i > 1) then output = output .. ", " end
			output = output .. tostring(newEffect)
        end
		
    end
	
	return output
end


function uespLog.DumpSkillsBasic()
	--GetNumAbilities() Returns: integer num
	--GetAbilityInfoByIndex(integer abilityIndex) Returns: string name, string texture, integer rank, integer actionSlotType, boolean passive, boolean showInSpellbook
	--GetNumAbilitiesLearnedForLevel(integer level, boolean progression) Returns: integer abilitiesLearned
	--GetLearnedAbilityInfoForLevel(integer level, integer learnedIndex, boolean progression) Returns: string name, string texture, integer abilityIndex, integer progressionIndex
	--PlayerHasAttributeUpgrades() Returns: boolean hasLevelUpgrades
	--ChooseAbilityProgressionMorph(integer progressionIndex, integer morph)
	
	--GetAbilityProgressionInfo(integer progressionIndex) Returns: string name, integer morph, integer rank
	--GetAbilityProgressionXPInfo(integer progressionIndex) Returns: integer lastRankXp, integer nextRankXP, integer currentXP, boolean atMorph
	--GetAbilityProgressionAbilityInfo(integer progressionIndex, integer morph, integer rank) Returns: string name, string texture, integer abilityIndex
	--GetAbilityProgressionRankFromAbilityId(integer abilityId) Returns: integer:nilable rank
	--GetAbilityProgressionXPInfoFromAbilityId(integer abilityId) Returns: boolean hasProgression, integer progressionIndex, integer lastRankXp, integer nextRankXP, integer currentXP, boolean atMorph
	--GetAttributeDerivedStatPerPointValue(integer attribute, integer stat) Returns: number amountPerPoint
	
	--GetAbilityIdByIndex(integer abilityIndex) Returns: integer abilityId
	
	--DoesAbilityExist(integer abilityId) Returns: boolean exists
	--GetAbilityProgressionRankFromAbilityId(integer abilityId) Returns: integer:nilable rank
	--GetAbilityProgressionXPInfoFromAbilityId(integer abilityId) Returns: boolean hasProgression, integer progressionIndex, integer lastRankXp, integer nextRankXP, integer currentXP, boolean atMorph
	
	local numAbilities = GetNumAbilities()
	local abilityIndex 
	local abilityId
	local validAbilityCount = 0
	local firstAbility = -1
	local lastAbility = -1
	
	uespLog.Msg("Dumping Basic Skill Info...")
	uespLog.Msg("    "..tostring(numAbilities).." Character Abilities")
	
	--for abilityIndex = 1, numAbilities do
		--local name, texture, rank, slotType, passive, showInSpellBook = GetAbilityInfoByIndex(abilityIndex)
		--uespLog.DebugMsg("       "..tostring(abilityIndex)..": "..tostring(name).." "..tostring(passive).." "..tostring(slotType).." "..tostring(showInSpellBook))
	--end
	
	for abilityId = 1, 199000 do
		if (DoesAbilityExist(abilityId)) then
			lastAbility = abilityId
			validAbilityCount = validAbilityCount + 1
			if (firstAbility < 0) then firstAbility = abilityId end
			
			local t1 = uespLog.CountVarReturns(GetAbilityUpgradeLines(abilityId))
			local t2 = uespLog.CountVarReturns(GetAbilityNewEffectLines(abilityId))
			
			if (t1 > 0 or t2 > 0) then
				--uespLog.DebugMsg("     "..tostring(abilityId).." upgrades "..tostring(t1).."  effects "..tostring(t2))
			end
		end
	end
	
	uespLog.Msg("     Found "..tostring(validAbilityCount).." abilities overall.")
	uespLog.Msg("     First at "..tostring(firstAbility).." , last at "..tostring(lastAbility))
	
	return true
end


function uespLog.CountVarReturns(...)
    local numReturns = select("#", ...)
	return numReturns
end


function uespLog.ClearSalesPrices()
	uespLog.SalesPrices = nil
end


function uespLog.CountVariableSize(object)
	uespLogcountVariables = {}
	
	local count, size = uespLog.CountVariableSizeSafe(object)
	
	uespLogcountVariables = {}
	
	uespLog.Msg("Variable size is "..size.." bytes in "..count.." subobjects.")
end


function uespLog.CountVariableSizeSafe(object)
	local size = 0
	local count = 0
	
	if (object == nil) then
		return 0, 0
	end
	
	local vType = type(object)
	
	if (vType ~= "table") then
	
		if (vType == "string") then
			size = size + #object + 24
		elseif (vType == "number") then
			size = size + 4 + 2
		elseif (vType == "boolean") then
			size = size + 4 + 1
		else
			size = size + 10
		end
		
		return 1, size
	end
	
	local stringName = tostring(object)
	
	if (uespLogcountVariables[stringName] ~= nil) then
		return 0, 0
	end
	
	size = size + 40
	count = count + 1
	local checkedKeys = {}
	
	for k, v in ipairs(object) do
		vType = type(v)
		
		tCount, tSize = uespLog.CountVariableSizeSafe(k)
		count = count + tCount
		size = size + tSize
				
		local tCount, tSize = uespLog.CountVariableSizeSafe(v)
		count = count + tCount
		size = size + tSize + 16
		
		checkedKeys[k] = 1
	end
	
	for k, v in pairs(object) do
	
		if (checkedKeys[k] == nil) then
			vType = type(v)
			
			tCount, tSize = uespLog.CountVariableSizeSafe(k)
			count = count + tCount
			size = size + tSize
			
			local tCount, tSize = uespLog.CountVariableSizeSafe(v)
			count = count + tCount
			size = size + tSize + 40
		end
	end
	
	return count, size
end


 function uespLog.countVariable(object)
	local size = 0
	local count = 0
	
	if (object == nil) then
		return 0, 0
	end
	
	for k, v in pairs(object) do
		local vType = type(v)
		local stringName = tostring(k)
		count = count + 1
		
		if (vType == "string") then
			size = size + #v + 2 + #stringName + 20
		elseif (vType == "number") then
			size = size + 4 + #stringName + 20
		elseif (vType == "boolean") then
			size = size + 5 + #stringName + 20
		elseif (vType == "table") then
			local tCount, tSize = uespLog.countVariable(v)
			count = count + tCount - 1
			size = size + tSize + #stringName
		end
	end
	
	return count, size
end


function uespLog.countSection(section)
	local size = 0
	local count = 0
	
	if (uespLog.savedVars[section] ~= nil) then
		count, size = uespLog.countVariable(uespLog.savedVars[section].data)
		
		if (section == "buildData") then
			count = #uespLog.savedVars[section].data
		end
	end
	
	uespLog.Msg("UESP: Section \"" .. tostring(section) .. "\" has " .. tostring(count) .. " records taking up " .. string.format("%.2f", size/1000000) .. " MB")
	
	return count, size
end


function uespLog.GetSectionCounts(section)
	local size = 0
	local count = 0
	
	if (uespLog.savedVars[section] ~= nil) then
		count, size = uespLog.countVariable(uespLog.savedVars[section].data)
	end

	return count, size
end


function uespLog.GetTraitCounts(craftingSkillType)
	local numLines = GetNumSmithingResearchLines(craftingSkillType)
	local numTraitItems = GetNumSmithingTraitItems()
	local tradeName = uespLog.GetCraftingName(craftingSkillType)
	local totalTraits = 0
	local totalKnown = 0
	
	for researchLineIndex = 1, numLines do
		local name, icon, numTraits, timeRequiredForNextResearchSecs = GetSmithingResearchLineInfo(craftingSkillType, researchLineIndex)
	
		for traitIndex = 1, numTraits do
			local traitType, traitDescription, known = GetSmithingResearchLineTraitInfo(craftingSkillType, researchLineIndex, traitIndex)
			
			if (traitType ~= nil and traitType ~= 0) then
			
				if (known) then
					totalKnown = totalKnown + 1
				end
				
				totalTraits = totalTraits + 1
			end
		end
	end

	return totalTraits, totalKnown
end


function uespLog.countTraits(craftingSkillType)
	local numLines = GetNumSmithingResearchLines(craftingSkillType)
	local numTraitItems = GetNumSmithingTraitItems()
	local tradeName = uespLog.GetCraftingName(craftingSkillType)
	local totalTraits = 0
	local totalKnown = 0
	
	for researchLineIndex = 1, numLines do
		local name, icon, numTraits, timeRequiredForNextResearchSecs = GetSmithingResearchLineInfo(craftingSkillType, researchLineIndex)
		local lineKnownCount = 0
		
		for traitIndex = 1, numTraits do
			local traitType, traitDescription, known = GetSmithingResearchLineTraitInfo(craftingSkillType, researchLineIndex, traitIndex)
			
			if (traitType ~= nil and traitType ~= 0) then
				local knownStr = "not known"
			
				if (known) then
					knownStr = "known"
					--uespLog.MsgColor(uespLog.traitColor, ".       "..uespLog.GetItemTraitName(traitType).." is "..knownStr)
					totalKnown = totalKnown + 1
					lineKnownCount = lineKnownCount + 1
				else
				end
				
				totalTraits = totalTraits + 1
			end
		end
		
		uespLog.MsgColor(uespLog.traitColor, ".     Traits for "..tradeName.."::"..tostring(name).." "..tostring(lineKnownCount).. " / "..tostring(numTraits))
	end

	uespLog.MsgColor(uespLog.traitColor, ".  You know "..totalKnown.." of "..totalTraits.." "..tradeName.." traits.")
end


SLASH_COMMANDS["/uespcount"] = function(cmd)

	if (cmd == "recipes") then
		uespLog.CountRecipes()
		return
	elseif (cmd == "inspiration") then
		uespLog.MsgColor(uespLog.countColor, "You have accumulated "..tostring(uespLog.GetTotalInspiration()).." crafting inspiration since the last reset")
		return
	elseif (cmd == "traits") then
		uespLog.countTraits(CRAFTING_TYPE_BLACKSMITHING)
		uespLog.countTraits(CRAFTING_TYPE_CLOTHIER)
		uespLog.countTraits(CRAFTING_TYPE_JEWELRYCRAFTING)
		uespLog.countTraits(CRAFTING_TYPE_WOODWORKING)
		return
	end
	
	local count1, size1 = uespLog.countSection("all")
	local count2, size2 = uespLog.countSection("globals")
	local count4, size4 = uespLog.countSection("buildData")
	local count5, size5 = uespLog.countSection("charData")
	local count6, size6 = uespLog.countSection("charInfo")
	local count7, size7 = uespLog.countSection("bankData")
	local count8, size8 = uespLog.countSection("craftBagData")
	local count9, size9 = uespLog.countSection("tempData")
	local count10, size10 = uespLog.countSection("skillCoef")
	local count = count1 + count2 + count4 + count5 + count6 + count7 + count8 + count9 + count10
	local size = size1 + size2  + size4 + size5 + size6 + size7 + size8 + size9 + size10
	
	uespLog.MsgColor(uespLog.countColor, "UESP: Total of " .. tostring(count) .. " records taking up " .. string.format("%.2f", size/1000000) .. " MB")
end


SLASH_COMMANDS["/uesphelp"] = function(cmd)
	uespLog.Msg("uespLog Addon v".. tostring(uespLog.version) .. " released ".. uespLog.releaseDate)
	uespLog.Msg("This add-on logs a variety of data to the saved variables folder.")
	uespLog.Msg("    /uespset      Access the add-on's settings menu")
	uespLog.Msg("    /uesplog      Turns the logging of data on and off")
	uespLog.Msg("    /uespcount    Displays statistics on the current log")
	uespLog.Msg("    /uespreset    Clears all or part of the logged data")
	uespLog.Msg("    /uespdebug    Turns the debug messages on and off")
	uespLog.Msg("    /uespdump     Outputs a variety of data to the log")
	uespLog.Msg("    /uesptime     Displays the various game times")
	uespLog.Msg("    /uespresearch Shows info on crafting research timers")
	uespLog.Msg("    /uespcolor    Turns color messages on and off")
	uespLog.Msg("    /loc          Displays your current location")
end


function uespLog.LogInventoryItem (bagId, slotIndex, event, extraData)
	local itemLink = GetItemLink(bagId, slotIndex, LINK_STYLE_DEFAULT)
	local itemName = tostring(GetItemName(bagId, slotIndex))
	local icon, stack, sellPrice, meetsUsageRequirement, locked, equipType, itemStyle, quality = GetItemInfo(bagId, slotIndex)
	local logData = {}

	if (itemName == "") then
		return false
	end
		
	uespLog.lastItemLink = itemLink
	uespLog.lastItemLinks[itemName] = itemLink
	
	extraData = extraData or {}
	extraData.itemStyle = itemStyle
	extraData.icon = icon
	extraData.locked = locked
	extraData.stack = stack
	extraData.bag = bagId
	extraData.slot = slotIndex
	
	uespLog.LogItemLink(itemLink, event, extraData)
	return true
end


function uespLog.DoesItemChangeWithLevelQuality (itemId, outputDiff)
	local itemLink1 = uespLog.MakeItemLink(itemId, 1, 1)
	local itemLink2 = uespLog.MakeItemLink(itemId, 50, 370)
	local itemLog1 = uespLog.CreateItemLinkLog(itemLink1)
	local itemLog2 = uespLog.CreateItemLinkLog(itemLink2)
	local returnValue = false
	
	local itemDiff = uespLog.CompareItemLogs(itemLog1, itemLog2)
	
	if (outputDiff) then
		uespLog.Msg("Comparing item data between "..tostring(itemLink1).." and "..tostring(itemLink2))
	end
	
	for k, v in pairs(itemDiff) do
		if (uespLog.ITEMCHANGE_IGNORE_FIELDS[k] == nil) then
		
			if (outputDiff) then
				uespLog.Msg(".    "..tostring(k))
				returnValue = true
			else
				return true
			end
		end
	end
	
	if (outputDiff and not returnValue) then
		uespLog.Msg(".     No changes detected in item data!")
	end
		
	return returnValue
end


function uespLog.CompareItemLinks (itemLink1, itemLink2)
	local itemLog1 = uespLog.CreateItemLinkLog(itemLink1)
	local itemLog2 = uespLog.CreateItemLinkLog(itemLink2)
	return uespLog.CompareItemLogs(itemLog1, itemLog2)
end


function uespLog.CompareItemLogs (itemLog1, itemLog2)
	local diffItem = { }

	for k, v in pairs(itemLog1) do
		if (v ~= itemLog2[k]) then
			diffItem[k] = itemLog2[k]
		end
	end
	
	for k, v in pairs(itemLog2) do
		if (itemLog1[k] == nil) then
			diffItem[k] = v
		end
	end
	
	return diffItem
end


uespLog.ITEMTRANSMUTETRAIT_IDS = {
		[18] = 4610,		-- Armor
		[17] = 88106,
		[12] = 61001,
		[16] = 89276,
		[20] = 7556,
		[19] = 7321,
		[13] = 5832,
		[11] = 1759,
		[15] = 26139,
		[14] = 44259,
		[25] = 89434,
		
		[22] = 29461,	-- Jewelry
		[21] = 54476,
		[24] = 15765,
		[23] = 55373,
 
		[31] = 139761,	-- Update 18	
		[29] = 140031,
		[33] = 140120,
		[27] = 138796,
		[32] = 140211,
		[28] = 139941,
		[30] = 139851,
		
		[5] = 89327,		-- 1H Weapons (double for 2H)
		[1] = 89281,
		[3] = 88033,
		[7] = 89341,
		[6] = 89401,
		[8] = 89381,
	
		[9] = 46281,		-- Weapons
		[10] = 49399,
		[2] = 89368,
		[4] = 89267,
		[26] = 89422,
}

uespLog.ITEMTRANSMUTETRAIT_2H_IDS = {
		
		[5] = 89332,		-- 2H Weapons		
		[1] = 89285,
		[3] = 88036,
		[7] = 89352,
		[6] = 88136,
		[8] = 88112,
				
		[9] = 46281,		-- Normal Weapons
		[10] = 49399,
		[2] = 89368,
		[4] = 89267,
		[26] = 89422,
}

uespLog.backupTraits = {}
uespLog.backupTraits2H = {}


function uespLog.CreateBackupTraits(backupTraits, trait, itemId)
	local i, value
	local level, quality
	
	for i, value in ipairs(uespLog.MINEITEM_LEVELS_SAFE) do
		local levelStart = value[1]
		local levelEnd = value[2]
		local qualityStart = value[3]
		local qualityEnd = value[4]
		local comment = value[5]
		
		for level = levelStart, levelEnd do
		
			if (backupTraits[level] == nil) then
				backupTraits[level] = {}
			end
			
			for quality = qualityStart, qualityEnd do
				local itemLink = uespLog.MakeItemLink(itemId, level, quality)
				local trait, traitDesc = GetItemLinkTraitInfo(itemLink)
				backupTraits[level][quality] = traitDesc
			end
		end
	end
end


function uespLog.LoadBackupTraits()

	for trait, itemId in pairs(uespLog.ITEMTRANSMUTETRAIT_IDS) do
		uespLog.backupTraits[trait] = {}
		uespLog.CreateBackupTraits(uespLog.backupTraits[trait], trait, itemId)
	end
	
	for trait, itemId in pairs(uespLog.ITEMTRANSMUTETRAIT_2H_IDS) do
		uespLog.backupTraits2H[trait] = {}
		uespLog.CreateBackupTraits(uespLog.backupTraits2H[trait], trait, itemId)
	end

end


function uespLog.CreateItemLinkLog (itemLink)
	local enchantName, enchantDesc
	local useAbilityName, useAbilityDesc, cooldown
	local traitText
	local setName, numSetBonuses
	local bookTitle
	local craftSkill
	local siegeType
	local hasCharges, hasEnchant, hasUseAbility, hasArmorDecay, isSetItem, isCrafted, isVendorTrash, isUnique, isUniqueEquipped
	local hasScaling, minLevel, maxLevel, isChampionPoints
	local isConsumable, isRune
	local flagString = ""
	local flavourText
	local tmp1, tmp2, tmp3
	local logData = { }
	local _, _, itemId, internalLevel, _, _, _, internalSubType  = uespLog.ParseLinkID(itemLink)
	
	logData.itemLink = itemLink
	
	logData.name = GetItemLinkName(itemLink)
	local isGunnySack = string.lower(logData.name) == "wet gunny sack"
	
	logData.type, logData.specialType = GetItemLinkItemType(itemLink)
	logData.icon = GetItemLinkIcon(itemLink)
	logData.itemStyle = GetItemLinkItemStyle(itemLink)
	--logData.icon, _, _, _, logData.itemStyle = GetItemLinkInfo(itemLink)
	
	logData.equipType = GetItemLinkEquipType(itemLink)
	logData.weaponType = GetItemLinkWeaponType(itemLink)
	logData.armorType = GetItemLinkArmorType(itemLink)
	logData.weaponPower = GetItemLinkWeaponPower(itemLink)
	logData.armorRating = GetItemLinkArmorRating(itemLink, false)
	logData.reqLevel = GetItemLinkRequiredLevel(itemLink)
	logData.reqCP = GetItemLinkRequiredChampionPoints(itemLink)
	logData.value = GetItemLinkValue(itemLink, false)
	logData.condition = GetItemLinkCondition(itemLink)
	logData.useType = GetItemLinkItemUseType(itemLink)
	logData.recipeRank = -1

	if (uespLog.MINEITEM_SHIELDARMORFACTOR ~= nil and uespLog.MINEITEM_SHIELDARMORFACTOR ~= 1 and logData.weaponType == 14) then
		logData.armorRating = logData.armorRating * uespLog.MINEITEM_SHIELDARMORFACTOR
	end
	
	if (logData.type == ITEMTYPE_FURNISHING) then
		logData.furnDataID = GetItemLinkFurnitureDataId(itemLink)
		logData.furnCate, logData.furnSubCate = GetFurnitureDataCategoryInfo(logData.furnDataID)
		logData.furnCateName = GetFurnitureCategoryName(logData.furnCate)
		logData.furnSubCateName = GetFurnitureCategoryName(logData.furnSubCate)
	end
	
	hasArmorDecay = DoesItemLinkHaveArmorDecay(itemLink)
	if (hasArmorDecay) then flagString = flagString .. "ArmorDecay " end
	
	hasCharges = DoesItemLinkHaveEnchantCharges(itemLink)
	
	if (hasCharges) then
		logData.maxCharges = GetItemLinkMaxEnchantCharges(itemLink)
	end

	hasEnchant, enchantName, enchantDesc = GetItemLinkEnchantInfo(itemLink)

	if (hasEnchant) then
		logData.enchantName = enchantName
		logData.enchantDesc = enchantDesc
	end

	hasUseAbility, useAbilityName, useAbilityDesc, cooldown, hasScaling, minLevel, maxLevel, isChampionPoints = GetItemLinkOnUseAbilityInfo(itemLink)
	
	if (isChampionPoints) then
		minLevel = 50 + math.floor(minLevel/10)
		maxLevel = 50 + math.floor(maxLevel/10)
	end

	if (hasUseAbility) then
		logData.useAbilityName = useAbilityName
		logData.useAbilityDesc = useAbilityDesc
		logData.useCooldown = cooldown
		logData.hasScaling = hasScaling
		logData.minLevel = minLevel
		logData.maxLevel = maxLevel
	end

	logData.trait, logData.traitDesc = GetItemLinkTraitInfo(itemLink)
	
	if (string.find(logData.traitDesc, "\0")) then
		--uespLog.Msg(itemLink.." Found bad trait: "..logData.traitDesc)
		
		local backupTraits = uespLog.backupTraits
		local reason = ""
		
		if (logData.equipType == 6) then
			backupTraits = uespLog.backupTraits2H
		end
	
		if (backupTraits) then
			backupTraits = backupTraits[logData.trait]
			
			if (backupTraits) then
				backupTraits = backupTraits[tonumber(internalLevel)]
				
				if (backupTraits) then
					backupTraits = backupTraits[tonumber(internalSubType)]
					
					if (not backupTraits) then
						reason = "Missing Subtype "..internalSubType
					end
				else
					reason = "Missing Level " .. internalLevel
				end
			else
				reason = "Missing Trait "..logData.trait
			end
		else
			reason = "Missing Top Level"
		end
		
		if (backupTraits) then
			logData.traitDesc = backupTraits
		else
			uespLog.Msg("No backup itemId found for trait " .. logData.trait .. " (" .. reason .. ")!")
		end
		
	end
	
	if (string.find(logData.traitDesc, "\0")) then
		uespLog.Msg("Error: Found bad trait: "..tostring(logData.traitDesc))
	end
	
	if (logData.traitDesc == "") then
		logData.traitDesc = nil
	end

	local isSetItem, setName, numSetBonuses, numSetEquipped, maxSetEquipped, setId = GetItemLinkSetInfo(itemLink)
			
	if (isSetItem) then
		logData.setId = setId
		logData.setName = setName
		logData.setBonusCount = numSetBonuses
		logData.setMaxCount = maxSetEquipped
		local i
		
		for i = 1, numSetBonuses do
			local setBonusRequired, setBonusDesc = GetItemLinkSetBonusInfo(itemLink, NOT_EQUIPPED, i)
			logData["setBonus"..tostring(i)] = tostring(setBonusRequired)
			logData["setDesc"..tostring(i)] = tostring(setBonusDesc)
		end
	end

	flavourText = GetItemLinkFlavorText(itemLink)
	if (flavourText ~= "") then logData.flavourText = flavourText end

		-- Only works for actually crafted items and has crash issue
	--isCrafted = IsItemLinkCrafted(itemLink)
	--if (isCrafted) then flagString = flagString .. "Crafted " end

	isVendorTrash = IsItemLinkVendorTrash(itemLink)
	if (isVendorTrash) then flagString = flagString .. "Vendor " end
	
	siegeType = GetItemLinkSiegeType(itemLink)
			
	if (siegeType > 0) then
		logData.siegeType = siegeType
		logData.maxSiegeHP = GetItemLinkSiegeMaxHP(itemLink)
	end

	logData.quality = GetItemLinkDisplayQuality(itemLink)
	
	isUnique = IsItemLinkUnique(itemLink)
	if (isUnique) then flagString = flagString .. "Unique " end
	
	isUniqueEquipped = IsItemLinkUniqueEquipped(itemLink)
	if (isUniqueEquipped) then flagString = flagString .. "UniqueEquipped " end
	
	isConsumable = IsItemLinkConsumable(itemLink)
	if (isConsumable) then flagString = flagString .. "Consumable " end

	runeKnown, logData.reagentTrait1 = GetItemLinkReagentTraitInfo(itemLink, 1)
	runeKnown, logData.reagentTrait2 = GetItemLinkReagentTraitInfo(itemLink, 2)
	runeKnown, logData.reagentTrait3 = GetItemLinkReagentTraitInfo(itemLink, 3)
	runeKnown, logData.reagentTrait4 = GetItemLinkReagentTraitInfo(itemLink, 4)
	
	isRune = IsItemLinkEnchantingRune(itemLink)
			
	if (isRune) then
		runeKnown, logData.runeName = GetItemLinkEnchantingRuneName(itemLink) 
		logData.runeType = GetItemLinkEnchantingRuneClassification(itemLink)
		logData.runeRank = GetItemLinkRequiredCraftingSkillRank(itemLink)		
	end

	craftSkill = GetItemLinkCraftingSkillType(itemLink)
		
	if (craftSkill > 0) then 
		logData.craftSkill = craftSkill 
	else
		logData.craftSkill = GetItemLinkRecipeCraftingSkillType(itemLink)
	end
	
	logData.refinedMatLink = GetItemLinkRefinedMaterialItemLink(itemLink)
	logData.matLevelDesc = GetItemLinkMaterialLevelDescription(itemLink)

	if (logData.matLevelDesc == "" and logData.refinedMatLink ~= "") then
		logData.matLevelDesc = GetItemLinkMaterialLevelDescription(logData.refinedMatLink)
	end
	
	if (logData.refinedMatLink ~= "") then
		logData.refinedMat = GetItemLinkName(logData.refinedMatLink)
		logData.refinedMatLink = nil
		
		if (logData.refinedMat == "") then
			logData.refinedMat = nil
		end
	end
	
	if (logData.matLevelDesc == "") then
		logData.matLevelDesc = nil
	end

	requiredQuality = GetItemLinkRecipeQualityRequirement(itemLink)
	logData.recipeQuality = requiredQuality

	if (GetItemLinkRecipeNumTradeskillRequirements ~= nil) then
		local numTradeskills = GetItemLinkRecipeNumTradeskillRequirements(itemLink)

		if (numTradeskills > 0) then
			logData.reqNumTrades = numTradeskills
			local tmp = {}
			
			for i = 1, numTradeskills do
				local tradeskill, reqLevel = GetItemLinkRecipeTradeskillRequirement(itemLink, i)
				
				logData["reqTrade"..tostring(i)] = tradeskill
				logData["reqRank"..tostring(i)] = reqLevel
				
				tmp[i] = GetCraftingSkillName(tradeskill) .. " " .. tostring(reqLevel)
				
				if (tradeskill == 5) then
					logData.recipeRank = reqLevel
				end
			end
			
			logData.reqTrades = uespLog.implodeOrder(tmp, ",")
		end
	elseif (GetItemLinkRecipeRankRequirement ~= nil) then
		logData.recipeRank = GetItemLinkRecipeRankRequirement(itemLink)
	end

	resultItemLink = GetItemLinkRecipeResultItemLink(itemLink)
	
	if (resultItemLink ~= nil and resultItemLink ~= "") then
		logData.recipeLink = resultItemLink
		
		local resultHasUseAbility, resultUuseAbilityName, resultUseAbilityDesc, resultCooldown, resultHasScaling, resultMinLevel, resultMaxLevel, resultIsChampionPoints = GetItemLinkOnUseAbilityInfo(resultItemLink)
	
		if (resultIsChampionPoints) then
			resultMinLevel = 50 + math.floor(resultMinLevel/10)
			resultMaxLevel = 50 + math.floor(resultMaxLevel/10)
		end
		
		logData.resultUseAbility = resultUseAbilityDesc
		logData.resultCooldown = resultCooldown
		logData.resultMinLevel = resultMinLevel
		logData.resultMaxLevel = resultMaxLevel
	end
	
	refinedItemLink = GetItemLinkRefinedMaterialItemLink(itemLink)
	
	if (refinedItemLink ~= nil and refinedItemLink ~= "") then
		logData.refinedItemLink = refinedItemLink
	end

	craftSkillRank = GetItemLinkRequiredCraftingSkillRank(itemLink)
	
	if (craftSkillRank ~= nil) then
		logData.craftSkillRank = craftSkillRank
	end

	local numIngredients = GetItemLinkRecipeNumIngredients(itemLink)
	local ingrList = {}
	
	for i = 1, numIngredients do
		local ingredientName, numOwned, numReq = GetItemLinkRecipeIngredientInfo(itemLink, i)
		if (numReq == nil) then numReq = 1 end
		logData["ingrName"..tostring(i)] = ingredientName
		logData["ingrQnt"..tostring(i)] = numReq
		
		if (numReq <= 1) then
			ingrList[#ingrList + 1] = tostring(ingredientName)
		else
			ingrList[#ingrList + 1] = tostring(ingredientName).." ("..tostring(numReq)..")"
		end
	end

	logData.recipeIngredients = table.concat(ingrList, ", ")
		
	--logData.isBound = IsItemLinkBound(itemLink)
	logData.bindType = GetItemLinkBindType(itemLink)
	
	if (not isGunnySack and isSafeSubType) then
		local glyphMinLevel, glyphMinCP = GetItemLinkGlyphMinLevels(itemLink)
		
		if (glyphMinLevel ~= nil) then
			logData.minGlyphLevel = glyphMinLevel
		elseif (glyphMinCP ~= nil) then
			logData.minGlyphLevel = 50 + math.floor(glyphMinCP/10)
		end
	end

	local traitAbilityCount = 0
	local maxTraits = GetMaxTraits()
	local isSafeSubType = not (uespLog.MINEITEM_UNSAFE_SUBTYPES[internalSubType] or false)
	
	if (isSafeSubType) then
	
		for i = 1, maxTraits  do
			local hasTraitAbility, traitAbilityDescription, traitCooldown, hasScaling, minLevel, maxLevel, isCP = GetItemLinkTraitOnUseAbilityInfo(itemLink, i)
			--local hasTraitAbility = false
			
			if (hasTraitAbility) then
				traitAbilityCount = traitAbilityCount + 1
				logData["traitAbility" .. tostring(traitAbilityCount) ] = traitAbilityDescription
				logData["traitCooldown" .. tostring(traitAbilityCount) ] = traitCooldown
			end
		end
		
	end
		
	bookTitle = GetItemLinkBookTitle(itemLink)
	--logData.isBookKnown = IsItemLinkBookKnown(itemLink)
	
	if (bookTitle ~= "") then
		logData.bookTitle = bookTitle
	end
	
	--local known, name = GetItemLinkReagentTraitInfo(itemLink, traitIndex) 
	
	if (flagString ~= "") then
		logData.flag = flagString
	end

	local tagString = ""
	
	if (GetItemLinkNumItemTags ~= nil) then
		local tagCount = GetItemLinkNumItemTags(itemLink)
	
		for i = 1, tagCount do
			local tagDesc = GetItemLinkItemTagDescription(itemLink, i)
			
			if (i > 1) then
				tagString = tagString .. ", "
			end
			
			tagString = tagString .. tagDesc
		end
	end
	
	if (tagString ~= "") then
		logData.tags = tagString
	end	
	
	logData.primaryDyeId, logData.secondaryDyeId, logData.accentDyeId = GetItemLinkDyeIds(itemLink)
	logData.dyeStampId = GetItemLinkDyeStampId(itemLink)
	
	if (logData.primaryDyeId > 0) then
		local r, g, b = GetDyeColorsById(logData.primaryDyeId)
		logData.primaryDyeColor = string.format("%.2x%.2x%.2x", math.floor(r * 255), math.floor(g * 255), math.floor(b * 255))
		logData.primaryDyeName = GetDyeInfoById(logData.primaryDyeId)
	end
	
	if (logData.secondaryDyeId > 0) then
		local r, g, b = GetDyeColorsById(logData.secondaryDyeId)
		logData.secondaryDyeColor = string.format("%.2x%.2x%.2x", math.floor(r * 255), math.floor(g * 255), math.floor(b * 255))
		logData.secondaryDyeName = GetDyeInfoById(logData.secondaryDyeId)
	end
	
	if (logData.accentDyeId > 0) then
		local r, g, b = GetDyeColorsById(logData.accentDyeId)
		logData.accentDyeColor = string.format("%.2x%.2x%.2x", math.floor(r * 255), math.floor(g * 255), math.floor(b * 255))
		logData.accentDyeName = GetDyeInfoById(logData.accentDyeId)
	end

	return logData
end


function uespLog.LogItemLink (itemLink, event, extraData)
	local logData = uespLog.CreateItemLinkLog(itemLink)
	logData.event = event
	
	extraData = extraData or {}
	
	if (extraData.magicItemId ~= nil) then
		logData.itemLink = string.gsub(itemLink, tostring(extraData.realItemId), tostring(extraData.magicItemId))
		extraData.magicItemId = nil
	end
	
	uespLog.AppendDataToLog("all", logData, extraData)
end


-- NOTE: Not currently used except for testing
function uespLog.LogItemLinkShort (itemLink, event, extraData)
	local enchantName, enchantDesc
	local useAbilityName, useAbilityDesc, cooldown
	local traitText
	local setName, numSetBonuses
	local bookTitle
	local logData = { }
	local craftSkill
	local siegeType
	local hasCharges, hasEnchant, hasUseAbility, hasArmorDecay, isSetItem, isCrafted, isVendorTrash, isUnique, isUniqueEquipped
	local isConsumable, isRune
	local flagString = ""
	local flavourText
	
	logData.event = event
	logData.itemLink = itemLink
	
	logData.weaponPower = GetItemLinkWeaponPower(itemLink)
	logData.armorRating = GetItemLinkArmorRating(itemLink, false)
	logData.reqLevel = GetItemLinkRequiredLevel(itemLink)
	logData.reqCP = GetItemLinkRequiredChampionPoints(itemLink)
	logData.value = GetItemLinkValue(itemLink, false)
	logData.condition = GetItemLinkCondition(itemLink)
		
	hasCharges = DoesItemLinkHaveEnchantCharges(itemLink)
	
	if (hasCharges) then
		logData.maxCharges = GetItemLinkMaxEnchantCharges(itemLink)
	end
	
	hasEnchant, enchantName, enchantDesc = GetItemLinkEnchantInfo(itemLink)
	
	if (hasEnchant) then
		logData.enchantName = enchantName
		logData.enchantDesc = enchantDesc
	end
	
	hasUseAbility, useAbilityName, useAbilityDesc, cooldown = GetItemLinkOnUseAbilityInfo(itemLink)
	
	if (hasUseAbility) then
		logData.useAbilityName = useAbilityName
		logData.useAbilityDesc = useAbilityDesc
		logData.useCooldown = cooldown
	end
	
	isSetItem, setName, numSetBonuses = GetItemLinkSetInfo(itemLink)
	
	if (logData.isSetItem) then
		logData.setName = setName
		logData.setBonusCount = numSetBonuses
		local i
		
		for i = 1, numSetBonuses do
			local setBonusRequired, setBonusDesc = GetItemLinkSetBonusInfo(itemLink, NOT_EQUIPPED, i)
			logData["setBonus"..tostring(i)] = tostring(setBonusRequired)
			logData["setDesc"..tostring(i)] = tostring(setBonusDesc)
		end
	end

	siegeType = GetItemLinkSiegeType(itemLink)
	
	if (siegeType > 0) then
		logData.maxSiegeHP = GetItemLinkSiegeMaxHP(itemLink)
	end
	
	logData.quality = GetItemLinkDisplayQuality(itemLink)

	uespLog.AppendDataToLog("all", logData, extraData)
end


function uespLog.DumpBag (bagId)
	local bagSlots = GetBagSize(bagId)
	local slotCount = 0
		
	for slotIndex = 1, bagSlots do
		local result = uespLog.LogInventoryItem(bagId, slotIndex, "InvDump")
		
		if (result) then
			slotCount = slotCount + 1
		end
	end
	
	return slotCount
end


function uespLog.DumpInventory ()
	local maxBags = GetMaxBags()
	local slotCount = 0
	
	local logData = { }
	logData.event = "InvDumpStart"
	uespLog.AppendDataToLog("all", logData, uespLog.GetTimeData())
	
	slotCount = slotCount + uespLog.DumpBag(BAG_WORN)	   			-- 0
	slotCount = slotCount + uespLog.DumpBag(BAG_BACKPACK)  			-- 1
	slotCount = slotCount + uespLog.DumpBag(BAG_BANK)	   			-- 2
	slotCount = slotCount + uespLog.DumpBag(BAG_SUBSCRIBER_BANK)	-- ?
	slotCount = slotCount + uespLog.DumpBag(BAG_BUYBACK)   			-- 3
	slotCount = slotCount + uespLog.DumpBag(BAG_GUILDBANK) 			-- 4
	
	logData = { }
	logData.event = "InvDumpEnd"
	uespLog.AppendDataToLog("all", logData)
	
	uespLog.Msg("Output ".. slotCount .." inventory items to log!")
end


function uespLog.GetAddress(obj)

	if type(obj) == "function" or type(obj) == "table" or type(obj) == "userdata" then
		return tostring(obj):match(": ([%u%d]+)")
	end
	
	return nil
end


function uespLog.DumpGlobalsIterateStart(maxLevel)
	local logData = {} 

	if (uespLog.dumpIterateEnabled) then
		uespLog.Msg("Dump globals iteration already running!")
		return
	end
	
	if (maxLevel == nil) then
		maxLevel = 3
	elseif (maxLevel < 0) then
		maxLevel = 0
	elseif (maxLevel > 10) then
		maxLevel = 10
	end
	
	uespLog.savedVars["globals"].data = { }

	uespLog.dumpIterateNextIndex = _nil
	uespLog.dumpIterateObject = _G
	uespLog.dumpIterateStatus = 0
	uespLog.dumpIterateCurrentLevel = 0
	uespLog.countGlobal = 0
	uespLog.countGlobalError = 0
	uespLog.dumpIterateParentName = ""
	uespLog.dumpIterateMaxLevel = maxLevel
	uespLog.dumpMetaTable = { }
	uespLog.dumpIndexTable = { }
	uespLog.dumpTableTable = { }
	uespLog.dumpIterateEnabled = true
		
	uespLog.Msg("Dumping globals iteratively to a depth of ".. tostring(uespLog.dumpIterateMaxLevel).."...")
	
	logData.event = "Global::Start"
	logData.niceDate = GetDate()
	logData.niceTime = GetTimeString()
	logData.apiVersion = GetAPIVersion() 
	uespLog.AppendDataToLog("globals", logData, uespLog.GetTimeData())

	zo_callLater(uespLog.DumpObjectIterate, uespLog.DUMP_ITERATE_TIMERDELAY)
end


function uespLog.DumpGlobalsIterateEnd()
	local logData = {} 

	if (not uespLog.dumpIterateEnabled) then
		uespLog.Msg("Dump globals iteration not running!")
		return
	end

	logData.event = "Global::End"
	uespLog.AppendDataToLog("globals", logData, uespLog.GetTimeData())
	
	uespLog.dumpIterateEnabled = false
	uespLog.Msg("Stopped dump globals iteration...")
	uespLog.Msg("Found ".. tostring(uespLog.countGlobal) .." objects and ".. tostring(uespLog.countGlobalError) .." private functions...")
	
	local metaSize = 0
	local indexSize = 0
	local tableSize = 0
	
	for _ in pairs(uespLog.dumpMetaTable) do metaSize = metaSize + 1 end
	for _ in pairs(uespLog.dumpIndexTable) do indexSize = indexSize + 1 end
	for _ in pairs(uespLog.dumpTableTable) do tableSize = tableSize + 1 end
	
	uespLog.Msg("Size of tables = "..tostring(metaSize) .. " / " .. tostring(indexSize) .. " / " ..tostring(tableSize))
end


function uespLog.DumpObjectInnerLoop(dumpObject, nextIndex, parentName, level, maxLevel)
	local skipMeta = false
	local skipTable = false
	local skipObject = false
	
	local status, tableIndex, value = pcall(next, dumpObject, nextIndex)
		
	if (tableIndex == nil) then
		return tableIndex
	end
	
	if (uespLog.dumpIgnoreObjects[tostring(tableIndex)] ~= nil) then
		skipObject = true
	end
			
	if (status and not skipObject) then
		skipTable, skipMeta = uespLog.DumpUpdateObjectTables(value)
	end
	
	if (not status) then
		local oldTableIndex = tableIndex
		tableIndex = uespLog.DumpObjectPrivate(tableIndex, value, parentName, level)
		uespLog.DebugExtraMsg("UESP: Error on dump object iteration...("..tostring(oldTableIndex)..", "..tostring(value)..", "..tostring(parentName)..")")
	elseif (skipObject) then
		uespLog.DebugExtraMsg("UESP: Skipping dump for object "..tostring(tableIndex))
	elseif (tableIndex == "__index" and uespLog.EndsWith(parentName, "__index")) then
		uespLog.DebugExtraMsg("UESP: Skipping dump for recursive __index")
	elseif type(value) == "table" then
		uespLog.DumpObjectTable(tableIndex, value, parentName, level)
		
		if (not skipTable and level < maxLevel) then
			uespLog.DumpObject(parentName, tableIndex, value, level+1, maxLevel)
		end
	elseif type(value) == "userdata" then		
		local indexTable = uespLog.GetIndexTable(value)
		
		uespLog.DumpObjectUserData(tableIndex, value, parentName, level)
		
		if (uespLog.dumpIterateUserTable and not skipMeta and indexTable ~= nil and level < maxLevel) then
			uespLog.DumpObject(parentName, tableIndex, indexTable, level+1, maxLevel)
		end

	elseif type(value) == "function" then
		uespLog.DumpObjectFunction(tableIndex, value, parentName, level)
	else
		uespLog.DumpObjectOther(tableIndex, value, parentName, level)
	end
	
	return tableIndex
end


function uespLog.DumpObjectIterate()
	local startCount = uespLog.countGlobal
	local startErrorCount = uespLog.countGlobalError
	local deltaCount

	if (not uespLog.dumpIterateEnabled) then
		return
	end
	
	uespLog.DebugExtraMsg("uespLog.DumpObjectIterate()")
	
	repeat
		local nextIndex = uespLog.DumpObjectInnerLoop(uespLog.dumpIterateObject, uespLog.dumpIterateNextIndex, uespLog.dumpIterateParentName, uespLog.dumpIterateCurrentLevel, uespLog.dumpIterateMaxLevel)
		
		if (nextIndex == nil) then
			uespLog.DumpGlobalsIterateEnd()
			return
		end
		
		deltaCount = uespLog.countGlobal - startCount
		uespLog.dumpIterateNextIndex = nextIndex

	until deltaCount >= uespLog.DUMP_ITERATE_LOOPCOUNT
	
	uespLog.Msg("Dump object created "..tostring(uespLog.countGlobal-startCount).." logs with "..tostring(uespLog.countGlobalError-startErrorCount).." errors.")
	
	zo_callLater(uespLog.DumpObjectIterate, uespLog.DUMP_ITERATE_TIMERDELAY)
end


function uespLog.DumpObjectTable (objectName, objectValue, parentName, varLevel)
	local logData = { }
	
	logData.event = "Global"
	logData.label = "Public"
	logData.type = "table"
	logData.meta = uespLog.GetAddress(getmetatable(objectValue))
	--logData.index = uespLog.GetAddress(uespLog.GetIndexTable(objectValue))  -- Same as meta for tables
	logData.name = parentName .. tostring(objectName)
	logData.value = uespLog.GetAddress(objectValue)
	
	if (uespLog.dumpTableTable[logData.value] == 1) then
		logData.firstTable = 1
	end
	
	if (logData.meta and uespLog.dumpMetaTable[logData.meta] == 1) then
		logData.firstMeta = 1
	end
		
	if (uespLog.logDumpObject) then
		uespLog.AppendDataToLog("globals", logData)
	end
	
	if (uespLog.printDumpObject) then
		uespLog.Msg("UESP:"..tostring(varLevel)..":table "..logData.name)
	end
	
	uespLog.countGlobal = uespLog.countGlobal + 1
end


function uespLog.DumpObjectUserData (objectName, objectValue, parentName, varLevel)
	local logData = { }
	
	logData.event = "Global"
	logData.label = "Public"
	logData.type = "userdata"
	logData.meta = uespLog.GetAddress(getmetatable(objectValue))
	logData.index = uespLog.GetAddress(uespLog.GetIndexTable(objectValue))
	logData.name = parentName .. tostring(objectName)
	logData.value = uespLog.GetAddress(objectValue)
	
	if (logData.meta and uespLog.dumpMetaTable[logData.meta] == 1) then
		logData.firstMeta = 1
	end
	
	if (logData.index and uespLog.dumpIndexTable[logData.index] == 1) then
		logData.firstIndex = 1
	end
	
	if (uespLog.logDumpObject) then
		uespLog.AppendDataToLog("globals", logData)
	end
	
	if (uespLog.printDumpObject) then
		uespLog.Msg("UESP: userdata "..logData.name)
	end
	
	uespLog.countGlobal = uespLog.countGlobal + 1
end


function uespLog.DumpObjectFunction (objectName, objectValue, parentName, varLevel)
	local logData = {} 
	
	logData.event = "Global"
	logData.type = "function"
	logData.label = "Public"
	logData.value = uespLog.GetAddress(objectValue)
	logData.name = parentName .. tostring(objectName) .. "()"
	
	if (uespLog.logDumpObject) then
		uespLog.AppendDataToLog("globals", logData)
	end
	
	if (uespLog.printDumpObject) then
		uespLog.Msg("UESP:"..tostring(varLevel)..":Function "..logData.name)
	end
	
	uespLog.countGlobal = uespLog.countGlobal + 1
end


function uespLog.DumpObjectOther (objectName, objectValue, parentName, varLevel)
	local objType = type(objectValue)
	local logData = {} 
	
	logData.event = "Global"
	logData.type = objType
	logData.label = "Public"
	logData.name = parentName .. tostring(objectName)
	logData.value = tostring(objectValue)
	
	if (objType == "number" and uespLog.BeginsWith(tostring(objectName), "SI_")) then
		logData.string = GetString(objectValue)
	end
		
	if (uespLog.logDumpObject) then
		uespLog.AppendDataToLog("globals", logData)
	end
	
	if (uespLog.printDumpObject) then
		uespLog.Msg("UESP:"..tostring(varLevel)..":Global "..logData.name.." = "..tostring(value))
	end
	
	uespLog.countGlobal = uespLog.countGlobal + 1
end


function uespLog.DumpObjectPrivate (objectName, objectValue, parentName, varLevel)
	local errIndex = string.match(objectName, "Attempt to access a private function '(%w*)' from")
	local logData = {} 
	
	logData.event = "Global"
	logData.label = "Private"
	logData.name = parentName .. tostring(errIndex) .. "()"
	
	if (uespLog.logDumpObject) then
		uespLog.AppendDataToLog("globals", logData)
	end
		
	if (uespLog.printDumpObject) then
		uespLog.Msg("UESP:"..tostring(level)..":Private "..logData.name)
	else
		--uespLog.DebugExtraMsg(".     "..tostring(level)..":Private "..logData.name)
	end
	
	uespLog.countGlobal = uespLog.countGlobal + 1
	uespLog.countGlobalError = uespLog.countGlobalError + 1
	
	return errIndex
end


function uespLog.GetIndexTable(var)
	local metaTable = getmetatable(var)
	
	if (metaTable == nil) then
		return nil
	end
	
	return metaTable.__index
end


function uespLog.DumpUpdateObjectTables (value)
	local metaTable = getmetatable(value)
	local indexTable = uespLog.GetIndexTable(value)
	local metaAddress = uespLog.GetAddress(metaTable)
	local indexAddress = uespLog.GetAddress(indexTable)
	local tableAddress = uespLog.GetAddress(value)
	local skipTable = false
	local skipMeta = false
	
	if (tableAddress ~= nil) then
	
		if (uespLog.dumpTableTable[tableAddress] ~= nil) then
			skipTable = true
		end
		
		uespLog.dumpTableTable[tableAddress] = (uespLog.dumpTableTable[tableAddress] or 0) + 1
	end
	
	if (metaAddress ~= nil) then
	
		if (uespLog.dumpMetaTable[metaAddress] ~= nil) then
			skipMeta = true
		end
		
		uespLog.dumpMetaTable[metaAddress] = (uespLog.dumpMetaTable[metaAddress] or 0) + 1
	end
	
	if (indexAddress ~= nil) then
	
		if (uespLog.dumpIndexTable[indexAddress] ~= nil) then
			skipMeta = true
		end
		
		uespLog.dumpIndexTable[indexAddress] = (uespLog.dumpIndexTable[indexAddress] or 0) + 1
	end
	
	return skipTable, skipMeta
end


function uespLog.DumpObject(prefix, varName, a, level, maxLevel) 
	local parentPrefix = ""
	local tableIndex = nil
	
	if (prefix ~= "_G" and prefix ~= "") then
		parentPrefix = prefix
		
		if (not uespLog.EndsWith(prefix, ".")) then
			parentPrefix = parentPrefix .. "."
		end
	end	
	
	if (varName ~= "_G" and varName ~= "") then
		parentPrefix = parentPrefix .. tostring(varName) .. "."
	end	
	
	newLevel = level + 1
	
		-- Special case for the global object
	if (varName == "_G") then
		if (newLevel > 1) then
			return
		end
	elseif (uespLog.dumpIgnoreObjects[varName] ~= nil) then
		return
	end
	
	repeat
		tableIndex = uespLog.DumpObjectInnerLoop(a, tableIndex, parentPrefix, level, maxLevel)
	until tableIndex == nil
	
end


function uespLog.DumpGlobals (maxLevel, baseObject)
	
		-- Clear global object
	uespLog.savedVars["globals"].data = { }
	
	uespLog.countGlobal = 0
	uespLog.countGlobalError = 0
	uespLog.dumpMetaTable = { }
	uespLog.dumpIndexTable = { }
	uespLog.dumpTableTable = { }
	
	if (baseObject == nil) then
		baseObject = _G
	end
	
	if (maxLevel == nil) then
		maxLevel = 3
	elseif (maxLevel < 0) then
		maxLevel = 0
	elseif (maxLevel > 10) then
		maxLevel = 10
	end
	
	uespLog.Msg("Dumping global objects to a depth of ".. tostring(maxLevel).."...")
	
	local logData = {} 
	logData.event = "Global::Start"
	logData.niceDate = GetDate()
	logData.niceTime = GetTimeString()
	logData.apiVersion = GetAPIVersion()
	uespLog.AppendDataToLog("globals", logData, uespLog.GetTimeData())
	
	uespLog.DumpObject("", "_G", baseObject, 0, maxLevel)
	
	logData = {} 
	logData.event = "Global::End"
	uespLog.AppendDataToLog("globals", logData, uespLog.GetTimeData())
		
	uespLog.Msg("Output ".. tostring(uespLog.countGlobal) .." global objects and ".. tostring(uespLog.countGlobalError) .." private functions to log...")
end


function uespLog.DumpRecipe (recipeListIndex, recipeIndex, extraData)

	local known, recipeName, numIngredients, provisionerLevelReq, qualityReq, specialIngredientType = GetRecipeInfo(recipeListIndex, recipeIndex)
	local resultName, resultIcon, resultStack, resultSellPrice, resultQuality = GetRecipeResultItemInfo(recipeListIndex, recipeIndex)
	local resultLink = GetRecipeResultItemLink(recipeListIndex, recipeIndex, LINK_STYLE_DEFAULT)
	local ingrCount = 0

	if (tostring(recipeName) == "") then
		return 0
	end
	
	logData = { }
	logData.event = "Recipe"
	logData.name = recipeName
	logData.numRecipes = numRecipes	
	logData.provLevel = provisionerLevelReq
	logData.numIngredients = numIngredients
	logData.quality = qualityReq
	logData.specialType = specialIngredientType
	uespLog.AppendDataToLog("all", logData, extraData)
	
	logData = { }
	logData.event = "Recipe::Result"
	logData.name = resultName
	logData.icon = resultIcon	
	logData.qnt = resultStack
	logData.value = resultSellPrice
	logData.quality = resultQuality
	logData.itemLink = resultLink
	uespLog.AppendDataToLog("all", logData, extraData)				
	
	for ingredientIndex = 1, numIngredients do
		local ingrName, ingrIcon, requiredQuantity, sellPrice, quality = GetRecipeIngredientItemInfo(recipeListIndex, recipeIndex, ingredientIndex)
		local itemLink = GetRecipeIngredientItemLink(recipeListIndex, recipeIndex, ingredientIndex, LINK_STYLE_DEFAULT)
		
		logData = { }
		logData.event = "Recipe::Ingredient"
		logData.name = ingrName
		logData.icon = ingrIcon	
		logData.qnt = requiredQuantity
		logData.value = sellPrice
		logData.quality = quality
		logData.itemLink = itemLink
		uespLog.AppendDataToLog("all", logData, extraData)	
		
		ingrCount = ingrCount + 1
	end
	
	return ingrCount
end	


function uespLog.DumpRecipes ()	
	local numRecipeLists = GetNumRecipeLists()
	local recipeCount = 0
	local ingrCount = 0
	local logData = { }
	
	for recipeListIndex = 1, numRecipeLists do
		local name, numRecipes, upIcon, downIcon, overIcon, disabledIcon, createSound = GetRecipeListInfo(recipeListIndex)
		
		logData = { }
		logData.event = "Recipe::List"
		logData.name = name
		logData.numRecipes = numRecipes
		uespLog.AppendDataToLog("all", logData, uespLog.GetTimeData())
		
		for recipeIndex = 1, numRecipes do
			ingrCount = ingrCount + uespLog.DumpRecipe(recipeListIndex, recipeIndex)
			recipeCount = recipeCount + 1
		end
	end
	
	logData = { }
	logData.event = "Recipe::End"
	uespLog.AppendDataToLog("all", logData)
	
	uespLog.Msg("".. tostring(recipeCount) .." recipes with ".. tostring(ingrCount) .." total ingredients to log...")
end


function uespLog.GetRecipeCounts()
	local numRecipeLists = GetNumRecipeLists()
	local recipeCount = 0
	local knownCount = 0
	local knownData = {}
	local resultIds = {}
	
	knownData["Food Recipes"] = {}
	knownData["Food Recipes"].name = "Food/Drink Recipes"
	knownData["Food Recipes"].known = 0
	knownData["Food Recipes"].count = 0
	
	knownData["Furniture Recipes"] = {}
	knownData["Furniture Recipes"].name = "Furniture Recipes"
	knownData["Furniture Recipes"].known = 0
	knownData["Furniture Recipes"].count = 0
	
	for recipeListIndex = 1, numRecipeLists do
		local name, numRecipes, upIcon, downIcon, overIcon, disabledIcon, createSound = GetRecipeListInfo(recipeListIndex)
		
		for recipeIndex = 1, numRecipes do
			local known, recipeName = GetRecipeInfo(recipeListIndex, recipeIndex)
			local category = "Food Recipes"
			
			if (recipeListIndex >= 17) then
				category = "Furniture Recipes"
			end
			
			recipeCount = recipeCount + 1
			
			if (knownData[name] == nil) then
				knownData[name] = {}
				knownData[name].name = name
				knownData[name].count = 0
				knownData[name].known = 0
			end
			
			knownData[name].count = knownData[name].count + 1
			knownData[category].count = knownData[category].count + 1
			
			if (known) then
				knownCount = knownCount + 1
				knownData[name].known = knownData[name].known + 1
				knownData[category].known = knownData[category].known + 1
			end
			
			local resultLink = GetRecipeResultItemLink(recipeListIndex, recipeIndex)
			local resultId = uespLog.ParseLinkItemId(resultLink)
			
			if (uespLog.MineRecipeResultIds[resultId] == nil) then
				--uespLog.Msg("" .. recipeListIndex ..":" .. recipeIndex .. " -- Missing recipe for result "..resultLink.."!")
			end
			
			if (resultId < 0) then
				--uespLog.Msg("" .. recipeListIndex ..":" .. recipeIndex .. " -- Missing result for recipe "..recipeName.."!")
			end
			
			--if (resultIds[resultLink] == nil) then resultIds[resultLink] = 0 end
			--resultIds[resultLink] = resultIds[resultLink] + 1
		end
	end
	
	--for link, count in pairs(resultIds) do
		--if (count > 1) then uespLog.Msg("Found duplicate result for recipe "..link.." ("..count..")") end
	--end
	
	return recipeCount, knownCount, knownData
end

	
function uespLog.CountRecipes()
	local recipeCount, knownCount, knownData = uespLog.GetRecipeCounts()
	
	for specialType, data in pairs(knownData) do
		uespLog.MsgColor(uespLog.countColor, "You know "..tostring(data.known).."/"..tostring(data.count).." "..data.name.." recipes.")
	end
	
	uespLog.MsgColor(uespLog.countColor, "You know "..tostring(knownCount).."/"..tostring(recipeCount).." recipes.")
end


function uespLog.GetAchievementCounts()
	local numCategories = GetNumAchievementCategories()
	local achCount = 0
	local completeCount = 0
	
	for categoryIndex = 1, numCategories do
		local categoryName, numSubCategories, numCateAchievements, earnedCatePoints, totalCatePoints, hidesCatePoints, normalIcon, pressedIcon, mouseoverIcon = GetAchievementCategoryInfo(categoryIndex)
		
		for subCategoryIndex = 1, numSubCategories do
			local subcategoryName, numsubCateAchievements, earnedSubCatePoints, totalSubCatePoints, hidesSubCatePoints = GetAchievementSubCategoryInfo(categoryIndex, subCategoryIndex)
						
			for achievementIndex = 1, numsubCateAchievements do
				local achievementId = GetAchievementId(categoryIndex, subCategoryIndex, achievementIndex)
				local achName, achDescription, achPoints, achIcon, achCompleted, achData, achTime = GetAchievementInfo(achievementId)
				achCount = achCount + 1
			
				if (achCompleted) then
					completeCount = completeCount + 1
				end
			end
		end
		
		for achievementIndex = 1, numCateAchievements do
			local achievementId = GetAchievementId(categoryIndex, subCategoryIndex, achievementIndex)
			local achName, achDescription, achPoints, achIcon, achCompleted, achData, achTime = GetAchievementInfo(achievementId)
			achCount = achCount + 1
		
			if (achCompleted) then
				completeCount = completeCount + 1
			end
		end
	end
	
	return achCount, completeCount
end
	
	
function uespLog.CountAchievements()	
	local achCount, completeCount = uespLog.GetAchievementCounts()
	uespLog.MsgColor(uespLog.countColor, "You have "..tostring(completeCount).."/"..tostring(achCount).." achievements.")	
end



function uespLog.DumpAchievementLinePriv (categoryIndex, subCategoryIndex, achievementIndex)
	local achievementId = GetAchievementId(categoryIndex, subCategoryIndex, achievementIndex)
	local firstId = GetFirstAchievementInLine(achievementId)
	local nextId = GetNextAchievementInLine(achievementId)
	local prevId = GetPreviousAchievementInLine(achievementId)
	local rewardCount = 0
	local criteriaCount = 0
	local currentId = firstId
	
	if (currentId == 0 or currentId == nil) then
		currentId = achievementId
	end
	
	while (currentId ~= nil and currentId > 0) do
		local rc, cc = uespLog.DumpAchievementPriv(currentId, categoryIndex, subCategoryIndex, achievementIndex)
		rewardCount = rewardCount + rc
		criteriaCount = criteriaCount + cc
		
		currentId = GetNextAchievementInLine(currentId)
	end
	
	return rewardCount, criteriaCount
end


function uespLog.DumpAchievementPriv (achievementId, categoryIndex, subCategoryIndex, achievementIndex)
	local achName, achDescription, achPoints, achIcon, achCompleted, achDate, achTime = GetAchievementInfo(achievementId)
	local numRewards = GetAchievementNumRewards(achievementId)	
	local numCriteria = GetAchievementNumCriteria(achievementId)
	local rewardCount = 0
	local criteriaCount = 0
	local logData = { }	
	
	logData.event = "Achievement"
	logData.categoryIndex = categoryIndex
	logData.subCategoryIndex = subCategoryIndex
	logData.achievementIndex = achievementIndex
	logData.categoryName = GetAchievementCategoryInfo(categoryIndex)
	
	if (subCategoryIndex == nil) then
		logData.subCategoryName = "General"
	else
		logData.subCategoryName = GetAchievementSubCategoryInfo(categoryIndex, subCategoryIndex)
	end
	
	logData.name = achName
	logData.description = achDescription
	logData.id = achievementId
	logData.points = achPoints
	logData.icon = achIcon
	logData.numRewards = numRewards
	logData.numCriteria = numCriteria
	logData.itemLink = GetAchievementItemLink(achievementId)
	logData.link = GetAchievementLink(achievementId)
	logData.firstId = GetFirstAchievementInLine(achievementId)
	logData.nextId = GetNextAchievementInLine(achievementId)
	logData.prevId = GetPreviousAchievementInLine(achievementId)
	logData.points = GetAchievementRewardPoints(achievementId)
	
	logData.hasItemReward, logData.itemName, logData.itemIcon, logData.itemQuality = GetAchievementRewardItem(achievementId)
	logData.hasTitleReward, logData.title = GetAchievementRewardTitle(achievementId)
	logData.hasDyeReward, logData.dyeId = GetAchievementRewardDye(achievementId)
	logData.hasCollectibleReward, logData.collectibleId = GetAchievementRewardCollectible(achievementId)
	
	if (logData.hasDyeReward) then
		logData.dyeName, _, logData.dyeRarity, logData.dyeHue, _, logData.dyeR, logData.dyeG, logData.dyeB, logData.dyeSortKey = GetDyeInfoById(logData.dyeId)
		rewardCount = rewardCount + 1
	end
	
	if (logData.hasItemReward) then rewardCount = rewardCount + 1 end
	if (logData.hasTitleReward) then rewardCount = rewardCount + 1 end
	if (logData.hasCollectibleReward) then rewardCount = rewardCount + 1 end

	uespLog.AppendDataToLog("all", logData)
		
	for criterionIndex = 1, numCriteria do
		local critDescription, critNumCompleted, critNumRequired = GetAchievementCriterion(achievementId, criterionIndex)
		
		logData = { }
		logData.event = "Achievement::Criteria"
		logData.id = achievementId
		logData.description = critDescription
		logData.numRequired = critNumRequired
		logData.index = criterionIndex
		uespLog.AppendDataToLog("all", logData)
		
		criteriaCount = criteriaCount + 1
	end

	return rewardCount, criteriaCount
end


function uespLog.DumpAchievements (note)
	local numCategories = GetNumAchievementCategories()
	local outputCount = 0
	local rewardCount = 0
	local criteriaCount = 0
	local categoryCount = 0
	local Msg = ""
	local logData = { }
	
	logData.event = "Achievement::Start"
	logData.note = note
	uespLog.AppendDataToLog("all", logData, uespLog.GetTimeData())
	
	for categoryIndex = 1, numCategories do
		local categoryName, numSubCategories, numCateAchievements, earnedCatePoints, totalCatePoints, hidesCatePoints = GetAchievementCategoryInfo(categoryIndex)
		local normalIcon, pressedIcon, mouseoverIcon = GetAchievementCategoryKeyboardIcons(categoryIndex)
		local gamepadIcon = GetAchievementCategoryGamepadIcon(categoryIndex)
		
		logData = { }
		logData.event = "Achievement::Category"
		logData.name = categoryName
		logData.categoryIndex = categoryIndex
		logData.subCategories = numSubCategories
		logData.numAchievements = numCateAchievements
		logData.points = totalCatePoints
		logData.hidesPoints = hidesCatePoints
		logData.icon = normalIcon
		logData.pressedIcon = pressedIcon
		logData.mouseoverIcon = mouseoverIcon
		logData.gamepadIcon = gamepadIcon
		uespLog.AppendDataToLog("all", logData)
		categoryCount = categoryCount + 1
		
		for subCategoryIndex = 1, numSubCategories do
			local subcategoryName, numSubCateAchievements, earnedSubCatePoints, totalSubCatePoints, hidesSubCatePoints = GetAchievementSubCategoryInfo(categoryIndex, subCategoryIndex)
			
			logData = { }
			logData.event = "Achievement::Subcategory"
			logData.name = subcategoryName
			logData.categoryName = categoryName
			logData.categoryIndex = categoryIndex
			logData.subCategoryIndex = subCategoryIndex
			logData.numAchievements = numSubCateAchievements
			logData.points = totalSubCatePoints
			logData.hidesPoints = hidesSubCatePoints
			uespLog.AppendDataToLog("all", logData)
			categoryCount = categoryCount + 1
			
			for achievementIndex = 1, numSubCateAchievements do
				local rc, cc = uespLog.DumpAchievementLinePriv(categoryIndex, subCategoryIndex, achievementIndex)
				rewardCount = rewardCount + rc
				criteriaCount = criteriaCount + cc
				outputCount = outputCount + 1
			end
		end
		
		for achievementIndex = 1, numCateAchievements do
			local rc, cc = uespLog.DumpAchievementLinePriv(categoryIndex, nil, achievementIndex)
			rewardCount = rewardCount + rc
			criteriaCount = criteriaCount + cc
			outputCount = outputCount + 1
		end

	end
	
	logData = { }
	logData.event = "Achievement::End"
	uespLog.AppendDataToLog("all", logData)
	
	uespLog.Msg("Output "..categoryCount.." categories, ".. outputCount .." achievements, ".. rewardCount.." rewards, and "..criteriaCount.." criterias to log!")
end


uespLog.IsIgnoredNPC = function (name)
	return (uespLog.ignoredNPCs[name] ~= nil)
end


uespLog.ClearSavedVarSection = function(section)

	if (uespLog.savedVars[section] ~= nil) then
		uespLog.savedVars[section].data = { }
		uespLog.NextSectionSizeWarning[section] = uespLog.FIRST_SECTION_SIZE_WARNING
		uespLog.NextSectionWarningGameTime[section] = 0
	end
	
end


function uespLog.IsValidItemId (itemId)
	local itemLink = uespLog.MakeItemLink(itemId, 1, 1)
	return uespLog.IsValidItemLink(itemLink)
end


function uespLog.IsValidItemLink (itemLink)
	--local icon = GetItemLinkIcon(itemLink)
	--return not (icon == nil or icon == "")
	
	--local name = GetItemLinkName(itemLink)
	--return not (name == nil or name == "")
	
	local itemId = GetItemLinkItemId(itemLink)
	return not (itemId == nil or itemId <= 0)
end


function uespLog.MineItemIterateLevels (itemId)
	local i, value
	local level, quality
	local setCount = 0
	local badItems = 0
	local itemLink
	local itemName
	local extraData = uespLog.GetTimeData()

	for i, value in ipairs(uespLog.MINEITEM_LEVELS_SAFE) do
		local levelStart = value[1]
		local levelEnd = value[2]
		local qualityStart = value[3]
		local qualityEnd = value[4]
		local comment = value[5]
		
		for level = levelStart, levelEnd do
			for quality = qualityStart, qualityEnd do
				setCount = setCount + 1
				uespLog.mineItemCount = uespLog.mineItemCount + 1
				
				itemLink = uespLog.MakeItemLinkEx( { itemId = itemId, level = level, quality = quality, style = 1 } )
				
				if (uespLog.IsValidItemLink(itemLink)) then
					extraData.comment = comment
					uespLog.LogItemLink(itemLink, "mineitem", extraData)
				else
					badItems = badItems + 1
					uespLog.mineItemBadCount = uespLog.mineItemBadCount + 1
				end				
				
				if (uespLog.mineItemCount % uespLog.mineUpdateItemCount == 0) then
					uespLog.MsgColor(uespLog.mineColor, ".     Mined "..tostring(uespLog.mineItemCount).." items, "..tostring(uespLog.mineItemBadCount).." bad...")
				end
			end
		end
	end
	
	--uespLog.MsgColor(uespLog.mineColor, "UESP: Made "..tostring(setCount).." items with ID "..tostring(itemId)..", "..tostring(badItems).." bad")
	return setCount, badCount
end


function uespLog.MineItemIterateLevelsShort (itemId)
	local i, value
	local level, quality
	local setCount = 0
	local badItems = 0
	local itemLink
	local itemName
	local extraData = { }
	local isFirst = true
	local fullItemLog = { }
	local lastItemLog = { }
	local newItemLog = { }
	local diffItemLog = { }

	for i, value in ipairs(uespLog.MINEITEM_LEVELS_SAFE) do
		local levelStart = value[1]
		local levelEnd = value[2]
		local qualityStart = value[3]
		local qualityEnd = value[4]
		local comment = value[5]
		isFirst = true
		
		for level = levelStart, levelEnd do
		
			if (uespLog.mineItemOnlyLevel < 0 or level == uespLog.mineItemOnlyLevel) then
			
				for quality = qualityStart, qualityEnd do
				
					if (uespLog.mineItemOnlySubType < 0 or quality == uespLog.mineItemOnlySubType) then
						setCount = setCount + 1
						uespLog.mineItemCount = uespLog.mineItemCount + 1
						
						itemLink = uespLog.MakeItemLinkEx( { itemId = itemId, level = level, quality = quality, style = 0 } )
						
						if (true or uespLog.IsValidItemLink(itemLink)) then
							
							if (isFirst) then
								isFirst = false
								extraData.comment = comment
								fullItemLog = uespLog.CreateItemLinkLog(itemLink)
								fullItemLog.event = "mineitem"
								uespLog.AppendDataToLog("all", fullItemLog, extraData)
								extraData.comment = nil
								lastItemLog = fullItemLog
							else
								newItemLog = uespLog.CreateItemLinkLog(itemLink)
								diffItemLog = uespLog.CompareItemLogs(lastItemLog, newItemLog)
								diffItemLog.event = "mi"
								uespLog.AppendDataToLog("all", diffItemLog, extraData)
								lastItemLog = newItemLog
							end
							
						else
							badItems = badItems + 1
							uespLog.mineItemBadCount = uespLog.mineItemBadCount + 1
						end				
						
						if (uespLog.mineItemCount % uespLog.mineUpdateItemCount == 0) then
							uespLog.MsgColor(uespLog.mineColor, ".     Mined "..tostring(uespLog.mineItemCount).." items, "..tostring(uespLog.mineItemBadCount).." bad...")
						end
					end
				end
			end
		end
	end
	
	--uespLog.MsgColor(uespLog.mineColor, "UESP: Made "..tostring(setCount).." items with ID "..tostring(itemId)..", "..tostring(badItems).." bad")
	return setCount, badCount
end


uespLog.MINEITEM_AUTOLOOPSAFE_MAXCOUNT = 500


function uespLog.MineItemIterateLevelsShortSafe (itemId, listIndex)
	local i, value
	local level, quality
	local setCount = 0
	local badItems = 0
	local itemLink
	local itemName
	local extraData = { }
	local isFirst = true
	local fullItemLog = { }
	local lastItemLog = { }
	local newItemLog = { }
	local diffItemLog = { }
	local validCount = 0
	
	--uespLog.Msg("Starting at: "..itemId..":"..listIndex)

	for i = listIndex, 10000 do
		local value = uespLog.MINEITEM_LEVELS_SAFE[i]
		
		if (value == nil) then
			return itemId + 1, 1, false
		end
		
		local levelStart = value[1]
		local levelEnd = value[2]
		local qualityStart = value[3]
		local qualityEnd = value[4]
		local comment = value[5]
		isFirst = true
		
		for level = levelStart, levelEnd do
		
			if (uespLog.mineItemOnlyLevel < 0 or level == uespLog.mineItemOnlyLevel) then
			
				for quality = qualityStart, qualityEnd do
				
					if (uespLog.mineItemOnlySubType < 0 or quality == uespLog.mineItemOnlySubType) then
						setCount = setCount + 1
						uespLog.mineItemCount = uespLog.mineItemCount + 1
						
						itemLink = uespLog.MakeItemLinkEx( { itemId = itemId, level = level, quality = quality, style = 0 } )
						
						if (true or uespLog.IsValidItemLink(itemLink)) then
							validCount = validCount + 1
							
							if (isFirst) then
								isFirst = false
								extraData.comment = comment
								fullItemLog = uespLog.CreateItemLinkLog(itemLink)
								fullItemLog.event = "mineitem"
								uespLog.AppendDataToLog("all", fullItemLog, extraData)
								extraData.comment = nil
								lastItemLog = fullItemLog
							else
								newItemLog = uespLog.CreateItemLinkLog(itemLink)
								diffItemLog = uespLog.CompareItemLogs(lastItemLog, newItemLog)
								diffItemLog.event = "mi"
								uespLog.AppendDataToLog("all", diffItemLog, extraData)
								lastItemLog = newItemLog
							end
							
						else
							badItems = badItems + 1
							uespLog.mineItemBadCount = uespLog.mineItemBadCount + 1
						end				
						
						if (uespLog.mineItemCount % uespLog.mineUpdateItemCount == 0) then
							uespLog.MsgColor(uespLog.mineColor, ".     Mined "..tostring(uespLog.mineItemCount).." items, "..tostring(uespLog.mineItemBadCount).." bad...")
						end
					end
				end
			end
		end
		
		if (validCount > uespLog.MINEITEM_AUTOLOOPSAFE_MAXCOUNT) then
			--uespLog.Msg("Stopping at: "..itemId..":"..i+1)
			return itemId, i + 1, true
		end		
		
	end
	
	--uespLog.MsgColor(uespLog.mineColor, "UESP: Made "..tostring(setCount).." items with ID "..tostring(itemId)..", "..tostring(badItems).." bad")
	return itemId + 1, 1, true
end


function uespLog.MineItemIterateOther (itemId)
	local itemLink
	local extraData = uespLog.GetTimeData()
	
	itemLink = uespLog.MakeItemLinkEx( { itemId = itemId, level = 1, quality = 1, style = 0 } )
	uespLog.mineItemCount = uespLog.mineItemCount + 1
	
	if (uespLog.mineItemCount % uespLog.mineUpdateItemCount == 0) then
		uespLog.MsgColor(uespLog.mineColor, ".     Mined "..tostring(uespLog.mineItemCount).." items, "..tostring(uespLog.mineItemBadCount).." bad...")
	end
	
	if (uespLog.IsValidItemLink(itemLink)) then
		uespLog.LogItemLink(itemLink, "mineitem", extraData)
	else
		uespLog.mineItemBadCount = uespLog.mineItemBadCount + 1
		return 1, 1
	end
	
	return 1, 0
end


function uespLog.MineItemIterateSafe (itemId, listIndex)
	
	if (not uespLog.IsValidItemId(itemId)) then
		uespLog.mineItemCount = uespLog.mineItemCount + 1
		uespLog.mineItemBadCount = uespLog.mineItemBadCount + 1
		return itemId + 1, 1, false
	end
	
	local itemLink = uespLog.MakeItemLink(itemId, 1, 1)
	local itemType = GetItemLinkItemType(itemLink)
	
	if (uespLog.mineItemOnlyItemType ~= nil and next(uespLog.mineItemOnlyItemType) ~= nil and uespLog.mineItemOnlyItemType[itemType] == nil) then
		uespLog.mineItemCount = uespLog.mineItemCount + 1
		uespLog.mineItemBadCount = uespLog.mineItemBadCount + 1
		return itemId + 1, 1, false
	end
	
	local changesWithLevel = uespLog.DoesItemChangeWithLevelQuality(itemId)
	
	if (changesWithLevel) then
		return uespLog.MineItemIterateLevelsShortSafe(itemId, listIndex)
	end
	
	uespLog.MineItemIterateOther(itemId)
	return itemId + 1, 1, false
end


function uespLog.MineItemIterate (itemId)
	
	if (not uespLog.IsValidItemId(itemId)) then
		uespLog.mineItemCount = uespLog.mineItemCount + 1
		uespLog.mineItemBadCount = uespLog.mineItemBadCount + 1
		return 1, 0
	end
	
	local itemLink = uespLog.MakeItemLink(itemId, 1, 1)
	local itemType = GetItemLinkItemType(itemLink)
	
	if (uespLog.mineItemOnlyItemType ~= nil and next(uespLog.mineItemOnlyItemType) ~= nil and uespLog.mineItemOnlyItemType[itemType] == nil) then
		uespLog.mineItemCount = uespLog.mineItemCount + 1
		uespLog.mineItemBadCount = uespLog.mineItemBadCount + 1
		return 1, 0
	end
	
	local changesWithLevel = uespLog.DoesItemChangeWithLevelQuality(itemId)
	
	if (changesWithLevel) then
		return uespLog.MineItemIterateLevelsShort(itemId)
	end
	
	return uespLog.MineItemIterateOther(itemId)
end


function uespLog.MineEnchantCharges()
	local i, value
	local enchantData = { }
	
	enchantData[1] = {
			[1] = "IntLevel",
			[2] = "IntType",
			[3] = "Level",
			[4] = "Quality",
			[5] = "NumCharges",
			[6] = "MaxCharges",
			[7] = "WeaponPower",
		}

	for i, value in ipairs(uespLog.MINEITEM_LEVELS_SAFE) do
		local levelStart = value[1]
		local levelEnd = value[2]
		local qualityStart = value[3]
		local qualityEnd = value[4]
		local comment = value[5]
		
		for level = levelStart, levelEnd do
			for quality = qualityStart, qualityEnd do
				
				itemLink = uespLog.MakeItemLinkEx( { 
						itemId = uespLog.MINEITEM_ENCHANT_ITEMID, 
						level = level, 
						quality = quality, 
						enchantId = uespLog.MINEITEM_ENCHANT_ENCHANTID,
						enchantLevel = level,
						enchantQuality = quality,
					} )
				
				if (uespLog.IsValidItemLink(itemLink)) then
					local maxCharges = GetItemLinkMaxEnchantCharges(itemLink)
					local numCharges = GetItemLinkNumEnchantCharges(itemLink)
					local hasCharges = DoesItemLinkHaveEnchantCharges(itemLink)
					local realQuality = GetItemLinkDisplayQuality(itemLink)
					local realLevel = GetItemLinkRequiredLevel(itemLink)
					local realCP = GetItemLinkRequiredChampionPoints(itemLink)
					local weaponPower = GetItemLinkWeaponPower(itemLink)
					
					enchantData[#enchantData + 1] = 
					{ 
						[1] = realLevel,
						[2] = realCP,
						[3] = quality,
						[4] = realLevel,
						[5] = realQuality,
						[6] = numCharges,
						[7] = maxCharges,
						[8] = weaponPower,
					}
				end
			end
		end
	end
	
	local data = uespLog.savedVars.tempData.data
	
	for i,row in ipairs(enchantData) do
		data[#data+1] = uespLog.implodeOrder(row, ", ")
	end
	
	uespLog.Msg("UESP: Logged "..tostring(#enchantData).." item enchantment charge data to tempData section.")
end


function uespLog.MineItemIteratePotionData (effectIndex, realItemId, potionItemId)
	local i, value
	local level, quality
	local itemLink
	local itemName
	local setCount = 0
	local badCount = 0
	local extraData = uespLog.GetTimeData()
	local isFirst = true
	local fullItemLog = { }
	local lastItemLog = { }
	local newItemLog = { }
	local diffItemLog = { }

	for i, value in ipairs(uespLog.MINEITEM_LEVELS_SAFE) do
		local levelStart = value[1]
		local levelEnd = value[2]
		local qualityStart = value[3]
		local qualityEnd = value[4]
		local comment = value[5]
		
		for level = levelStart, levelEnd do
			for quality = qualityStart, qualityEnd do
				setCount = setCount + 1
				uespLog.mineItemCount = uespLog.mineItemCount + 1
				
				itemLink = uespLog.MakeItemLinkEx( { itemId = realItemId, level = level, quality = quality, potionEffect = effectIndex } )
				
				if (uespLog.IsValidItemLink(itemLink)) then
				
					if (isFirst) then
						isFirst = false
						
						extraData.comment = comment
						extraData.realItemId = realItemId
						extraData.magicItemId = potionItemId
												
						fullItemLog = uespLog.CreateItemLinkLog(itemLink)
						
						fullItemLog.event = "mineitem"
						fullItemLog.itemLink = string.gsub(fullItemLog.itemLink, tostring(extraData.realItemId), tostring(potionItemId))
						
						uespLog.AppendDataToLog("all", fullItemLog, extraData)
						extraData.comment = nil
						lastItemLog = fullItemLog
					else
						newItemLog = uespLog.CreateItemLinkLog(itemLink)
						
						extraData.comment = comment
						extraData.realItemId = realItemId
						extraData.magicItemId = potionItemId
						
						diffItemLog = uespLog.CompareItemLogs(lastItemLog, newItemLog)
						diffItemLog.itemLink = newItemLog.itemLink
						diffItemLog.event = "mi"
						diffItemLog.itemLink = string.gsub(diffItemLog.itemLink, tostring(extraData.realItemId), tostring(potionItemId))
						
						uespLog.AppendDataToLog("all", diffItemLog, extraData)
						lastItemLog = newItemLog
					end					

				else
					badItems = badItems + 1
					uespLog.mineItemBadCount = uespLog.mineItemBadCount + 1
				end				
				
				if (uespLog.mineItemCount % uespLog.mineUpdateItemCount == 0) then
					--uespLog.MsgColor(uespLog.mineColor, ".     Mined "..tostring(uespLog.mineItemCount).." potion data, "..tostring(uespLog.mineItemBadCount).." bad...")
				end
				
			end
		end
	end
	
	local typeMsg = "potion"
	
	if (realItemId == uespLog.MINEITEM_POISON_ITEMID) then
		typeMsg = "poison"
	end
	
	uespLog.MsgColor(uespLog.mineColor, "UESP: Auto-mined "..tostring(setCount).." "..typeMsg.." data, "..
				tostring(badCount).." bad, effect "..tostring(effectIndex)..
				" (total "..tostring(uespLog.mineItemCount - uespLog.mineItemBadCount).." items)")	
	
	return setCount, badCount
end


function uespLog.MineItemIteratePotionDataSafe (effectIndex, realItemId, potionItemId, listIndex)
	local i, value
	local level, quality
	local itemLink
	local itemName
	local setCount = 0
	local badCount = 0
	local validCount = 0
	local extraData = uespLog.GetTimeData()
	local isFirst = true
	local fullItemLog = { }
	local lastItemLog = { }
	local newItemLog = { }
	local diffItemLog = { }
	local nextEffectIndex = effectIndex
	local nextListIndex = listIndex

	for i = listIndex, 10000 do
		local value = uespLog.MINEITEM_LEVELS_SAFE[i]
		
		if (value == nil) then
			nextEffectIndex = effectIndex + 1
			nextListIndex = 1
			break
		end
	
		local levelStart = value[1]
		local levelEnd = value[2]
		local qualityStart = value[3]
		local qualityEnd = value[4]
		local comment = value[5]
		
		for level = levelStart, levelEnd do
			for quality = qualityStart, qualityEnd do
				setCount = setCount + 1
				uespLog.mineItemCount = uespLog.mineItemCount + 1
				
				itemLink = uespLog.MakeItemLinkEx( { itemId = realItemId, level = level, quality = quality, potionEffect = effectIndex } )
				
				if (uespLog.IsValidItemLink(itemLink)) then
					validCount = validCount + 1
				
					if (isFirst) then
						isFirst = false
						
						extraData.comment = comment
						extraData.realItemId = realItemId
						extraData.magicItemId = potionItemId
												
						fullItemLog = uespLog.CreateItemLinkLog(itemLink)
						
						fullItemLog.event = "mineitem"
						fullItemLog.itemLink = string.gsub(fullItemLog.itemLink, tostring(extraData.realItemId), tostring(potionItemId))
						
						uespLog.AppendDataToLog("all", fullItemLog, extraData)
						extraData.comment = nil
						lastItemLog = fullItemLog
					else
						newItemLog = uespLog.CreateItemLinkLog(itemLink)
						
						extraData.comment = comment
						extraData.realItemId = realItemId
						extraData.magicItemId = potionItemId
						
						diffItemLog = uespLog.CompareItemLogs(lastItemLog, newItemLog)
						diffItemLog.itemLink = newItemLog.itemLink
						diffItemLog.event = "mi"
						diffItemLog.itemLink = string.gsub(diffItemLog.itemLink, tostring(extraData.realItemId), tostring(potionItemId))
						
						uespLog.AppendDataToLog("all", diffItemLog, extraData)
						lastItemLog = newItemLog
					end					

				else
					badItems = badItems + 1
					uespLog.mineItemBadCount = uespLog.mineItemBadCount + 1
				end				
				
				if (uespLog.mineItemCount % uespLog.mineUpdateItemCount == 0) then
					--uespLog.MsgColor(uespLog.mineColor, ".     Mined "..tostring(uespLog.mineItemCount).." potion data, "..tostring(uespLog.mineItemBadCount).." bad...")
				end
				
			end
		end
		
		if (validCount > uespLog.MINEITEM_AUTOLOOPSAFE_MAXCOUNT/2) then
			--uespLog.Msg("Stopping at: "..itemId..":"..i+1)
			nextListIndex = i + 1
			break
		end		
		
	end
	
	local typeMsg = "potion"
	
	if (realItemId == uespLog.MINEITEM_POISON_ITEMID) then
		typeMsg = "poison"
	end
	
	uespLog.MsgColor(uespLog.mineColor, "UESP: Auto-mined "..tostring(setCount).." "..typeMsg.." data, "..
				tostring(badCount).." bad, effect "..tostring(effectIndex)..
				" (total "..tostring(uespLog.mineItemCount - uespLog.mineItemBadCount).." items)")	
	
	return nextEffectIndex, nextListIndex, true
end


function uespLog.MineItems (startId, endId)
	local itemLink
	local itemName
	local logData
	local itemCount = 0
	local badCount = 0
	local itemId
	
	uespLog.mineItemBadCount = 0
	uespLog.mineItemCount = 0
	uespLog.MsgColor(uespLog.mineColor, "UESP: Mining items from IDs "..tostring(startId).." to "..tostring(endId))
	
	if (uespLog.mineItemOnlyLevel >= 0) then
		uespLog.MsgColor(uespLog.mineColor, ".     Only mining items with internal level of "..tostring(uespLog.mineItemOnlyLevel))
	end
	
	if (uespLog.mineItemOnlySubType >= 0) then
		uespLog.MsgColor(uespLog.mineColor, ".     Only mining items with internal type of "..tostring(uespLog.mineItemOnlySubType))
	end
	
	local text = uespLog.implodeKeys(uespLog.mineItemOnlyItemType, ", ")
	
	if (text ~= "") then
		uespLog.MsgColor(uespLog.mineColor, ".     Only mining items with item types of "..text)
	end
	
	logData = { }
	logData.startId = startId
	logData.endId = endId
	logData.event = "mineitem::Start"
	uespLog.AppendDataToLog("all", logData, uespLog.GetTimeData())

	for itemId = startId, endId do
		uespLog.MineItemIterate(itemId)
	end
	
	uespLog.mineNextItemId = endId + 1
	
	logData = { }
	logData.event = "mineitem::End"
	uespLog.AppendDataToLog("all", logData, uespLog.GetTimeData())
	
	uespLog.MsgColor(uespLog.mineColor, ".    Finished Mining "..tostring(uespLog.mineItemCount).." items, "..tostring(uespLog.mineItemBadCount).." bad")
end


uespLog.MineSingleItemSafe_FinishCallback = nil


function uespLog.MineSingleItemSafe (itemId)
	local itemLink
	local itemName
	local logData
	local itemCount = 0
	local badCount = 0
	
	uespLog.mineItemBadCount = 0
	uespLog.mineItemCount = 0
	uespLog.MsgColor(uespLog.mineColor, "UESP: Starting to mine item "..tostring(itemId).."...")
	
	if (uespLog.mineItemOnlyLevel >= 0) then
		uespLog.MsgColor(uespLog.mineColor, ".     Only mining items with internal level of "..tostring(uespLog.mineItemOnlyLevel))
	end
	
	if (uespLog.mineItemOnlySubType >= 0) then
		uespLog.MsgColor(uespLog.mineColor, ".     Only mining items with internal type of "..tostring(uespLog.mineItemOnlySubType))
	end
	
	local text = uespLog.implodeKeys(uespLog.mineItemOnlyItemType, ", ")
	
	if (text ~= "") then
		uespLog.MsgColor(uespLog.mineColor, ".     Only mining items with item types of "..text)
	end

	uespLog.MineSingleItemSafe_Next(itemId, 1)
end


function uespLog.MineSingleItemSafe_Next (itemId, listIndex)

	uespLog.MsgColor(uespLog.mineColor, "UESP: Mining data for item "..tostring(itemId).."...")
	
	local nextItemId, nextListIndex, mineSuccess = uespLog.MineItemIterateLevelsShortSafe(itemId, listIndex)
		
	if (nextItemId ~= itemId) then
		uespLog.MsgColor(uespLog.mineColor, "UESP: Finished mining item "..tostring(itemId)..".")
	
		if (uespLog.MineSingleItemSafe_FinishCallback ~= nil) then
			uespLog.MineSingleItemSafe_FinishCallback()
		end
		
		return
	end
		
	zo_callLater(function() uespLog.MineSingleItemSafe_Next(itemId, nextListIndex) end, 2000)
end


function uespLog.MineItemsAutoLoop()
	local initItemCount = uespLog.mineItemCount
	local initBadCount = uespLog.mineItemBadCount
	local initItemId = uespLog.mineItemsAutoNextItemId
	local itemId
	local reloadUI = true
	local i	
	
	if (not uespLog.isAutoMiningItems) then
		return
	end
	
	for i = 1, uespLog.MINEITEMS_AUTOLOOPCOUNT do
	
		if (#uespLog.savedVars.all.data >= uespLog.MINEITEMS_AUTOSTOP_LOGCOUNT or uespLog.mineItemsAutoNextItemId > uespLog.mineItemsAutoLastItemId) then
		
			if (uespLog.mineItemsAutoNextItemId > uespLog.mineItemsAutoLastItemId) then	
				if (uespLog.mineItemsAutoLastItemId >= uespLog.MINEITEM_AUTO_MAXITEMID) then
					uespLog.MsgColor(uespLog.mineColor, "Stopped auto-mining at item "..tostring(uespLog.mineItemsAutoNextItemId).." due to reaching max ID.")
				else
					reloadUI = false
					uespLog.MsgColor(uespLog.mineColor, "Stopped auto-mining at item "..tostring(uespLog.mineItemsAutoNextItemId).." due to reaching last ID.")
				end
			elseif (initItemId < uespLog.mineItemsAutoNextItemId) then
				uespLog.MsgColor(uespLog.mineColor, "Paused auto-mining at item "..tostring(uespLog.mineItemsAutoNextItemId).." due to full log.")
			end
			
			if (not uespLog.mineItemAutoRestartOutputEnd) then
				uespLog.MineItemsOutputEndLog()
				uespLog.mineItemAutoRestartOutputEnd = true
			end
			
			local reloadTime = uespLog.mineItemLastReloadTimeMS + uespLog.mineItemReloadDelay - GetGameTimeMilliseconds()

			if (uespLog.mineItemAutoReload and reloadTime <= 0) then
			
				if (reloadUI) then
					uespLog.MsgColor(uespLog.mineColor, "Item mining auto reloading UI....")
					SLASH_COMMANDS["/reloadui"]()
				else
					uespLog.mineItemAutoReload = false
					uespLog.mineItemAutoRestart = false
					uespLog.savedVars.settings.data.mineItemAutoReload = false
					uespLog.savedVars.settings.data.mineItemAutoRestart = false
					uespLog.isAutoMiningItems = false
					uespLog.savedVars.settings.data.isAutoMiningItems = false
					return
				end
			elseif (uespLog.mineItemAutoReload) then
				uespLog.MsgColor(uespLog.mineColor, "Item mining auto UI reload in "..tostring(math.ceil(reloadTime/5000)*5).." secs...")
			end
			
			break
		end
		
		itemId = uespLog.mineItemsAutoNextItemId
		uespLog.mineItemsAutoNextItemId = uespLog.mineItemsAutoNextItemId + 1
		uespLog.savedVars.settings.data.mineItemsAutoNextItemId = uespLog.mineItemsAutoNextItemId
		
		uespLog.MineItemIterate(itemId)
		
		if (uespLog.mineItemCount - initItemCount > uespLog.MINEITEMS_AUTOMAXLOOPCOUNT) then
			break
		end

	end

		-- Chain the call to keep going if required
	if (uespLog.isAutoMiningItems) then
	
		if (initItemId < uespLog.mineItemsAutoNextItemId) then
			zo_callLater(uespLog.MineItemsAutoLoop, uespLog.MINEITEMS_AUTODELAY)
		elseif (uespLog.mineItemAutoReload) then
			zo_callLater(uespLog.MineItemsAutoLoop, uespLog.MINEITEMS_AUTODELAY * 5)
		end
	end
	
	if (initItemId < uespLog.mineItemsAutoNextItemId) then
		uespLog.MsgColor(uespLog.mineColor, "Auto-mined "..tostring(uespLog.mineItemCount - initItemCount).." items, "..
				tostring(uespLog.mineItemBadCount - initBadCount).." bad, IDs "..tostring(initItemId).."-"..tostring(itemId)..
				" (total "..tostring(uespLog.mineItemCount - uespLog.mineItemBadCount).." items)")	
	end
end


function uespLog.MineItemsAutoLoopSafe()
	local initItemCount = uespLog.mineItemCount
	local initBadCount = uespLog.mineItemBadCount
	local initItemId = uespLog.mineItemsAutoNextItemId
	local itemId
	local reloadUI = true
	local i	
	
	if (not uespLog.isAutoMiningItems) then
		return
	end
	
	for i = 1, uespLog.MINEITEMS_AUTOLOOPCOUNT do
	
		if (#uespLog.savedVars.all.data >= uespLog.MINEITEMS_AUTOSTOP_LOGCOUNT or uespLog.mineItemsAutoNextItemId > uespLog.mineItemsAutoLastItemId) then
		
			if (uespLog.mineItemsAutoNextItemId > uespLog.mineItemsAutoLastItemId) then	
				if (uespLog.mineItemsAutoLastItemId >= uespLog.MINEITEM_AUTO_MAXITEMID) then
					uespLog.MsgColor(uespLog.mineColor, "Stopped auto-mining at item "..tostring(uespLog.mineItemsAutoNextItemId).." due to reaching max ID.")
				else
					reloadUI = false
					uespLog.MsgColor(uespLog.mineColor, "Stopped auto-mining at item "..tostring(uespLog.mineItemsAutoNextItemId).." due to reaching last ID.")
				end
			elseif (initItemId < uespLog.mineItemsAutoNextItemId) then
				uespLog.MsgColor(uespLog.mineColor, "Paused auto-mining at item "..tostring(uespLog.mineItemsAutoNextItemId).." due to full log.")
			end
			
			if (not uespLog.mineItemAutoRestartOutputEnd) then
				uespLog.MineItemsOutputEndLog()
				uespLog.mineItemAutoRestartOutputEnd = true
			end
			
			local reloadTime = uespLog.mineItemLastReloadTimeMS + uespLog.mineItemReloadDelay - GetGameTimeMilliseconds()

			if (uespLog.mineItemAutoReload and reloadTime <= 0) then
			
				if (reloadUI) then
					uespLog.MsgColor(uespLog.mineColor, "Item mining auto reloading UI....")
					SLASH_COMMANDS["/reloadui"]()
				else
					uespLog.mineItemAutoReload = false
					uespLog.mineItemAutoRestart = false
					uespLog.savedVars.settings.data.mineItemAutoReload = false
					uespLog.savedVars.settings.data.mineItemAutoRestart = false
					uespLog.isAutoMiningItems = false
					uespLog.savedVars.settings.data.isAutoMiningItems = false
					return
				end
			elseif (uespLog.mineItemAutoReload) then
				uespLog.MsgColor(uespLog.mineColor, "Item mining auto UI reload in "..tostring(math.ceil(reloadTime/5000)*5).." secs...")
			end
			
			break
		end
		
		itemId = uespLog.mineItemsAutoNextItemId
		listIndex = uespLog.mineItemsAutoNextListIndex
				
		local nextItemId, nextListIndex, shouldStop = uespLog.MineItemIterateSafe(itemId, listIndex)
		
		uespLog.mineItemsAutoNextItemId = nextItemId
		uespLog.mineItemsAutoNextListIndex = nextListIndex
		uespLog.savedVars.settings.data.mineItemsAutoNextItemId = nextItemId
		uespLog.savedVars.settings.data.mineItemsAutoNextListIndex = nextListIndex
		
		if (shouldStop or uespLog.mineItemCount - initItemCount > uespLog.MINEITEMS_AUTOMAXLOOPCOUNT) then
			break
		end

	end

		-- Chain the call to keep going if required
	if (uespLog.isAutoMiningItems) then
		zo_callLater(uespLog.MineItemsAutoLoopSafe, uespLog.MINEITEMS_AUTODELAY)
	end
	
	uespLog.MsgColor(uespLog.mineColor, "Auto-mined "..tostring(uespLog.mineItemCount - initItemCount).." items, "..
				tostring(uespLog.mineItemBadCount - initBadCount).." bad, IDs "..tostring(initItemId).."-"..tostring(itemId)..
				" (total "..tostring(uespLog.mineItemCount - uespLog.mineItemBadCount).." items)")	
end


function uespLog.MineItemsAutoLoopPotionData ()
	local initItemId
	
	if (not uespLog.isAutoMiningItems) then
		return
	end
	
	uespLog.MineItemIteratePotionDataSafe(uespLog.mineItemPotionDataEffectIndex, uespLog.MINEITEM_POTION_ITEMID, uespLog.MINEITEM_POTION_MAGICITEMID, uespLog.mineItemPotionDataListIndex)
	
	local nextEffectIndex, nextListIndex = uespLog.MineItemIteratePotionDataSafe(uespLog.mineItemPotionDataEffectIndex, uespLog.MINEITEM_POISON_ITEMID, uespLog.MINEITEM_POISON_MAGICITEMID, uespLog.mineItemPotionDataListIndex)
	
	uespLog.mineItemPotionDataEffectIndex = nextEffectIndex
	uespLog.mineItemPotionDataListIndex = nextListIndex
	uespLog.savedVars.settings.data.mineItemPotionDataEffectIndex = uespLog.mineItemPotionDataEffectIndex

		-- Chain the call to keep going if required
	if (uespLog.isAutoMiningItems) then
		if (uespLog.mineItemPotionDataEffectIndex > uespLog.MINEITEM_POTION_MAXEFFECTINDEX) then
			uespLog.MineItemsAutoEnd()
		else
			zo_callLater(uespLog.MineItemsAutoLoopPotionData, uespLog.MINEITEMS_AUTODELAY)
		end
	end
	
end


function uespLog.MineItemsAutoStart ()
	local logData

	if (uespLog.isAutoMiningItems) then
		return
	end
	
	uespLog.mineItemBadCount = 0
	uespLog.mineItemCount = 0
	
	uespLog.MineItemsOutputStartLog()
		
	if (uespLog.mineItemPotionData) then
		uespLog.MineItemsAutoStartPotionData()
		return
	end
	
	uespLog.isAutoMiningItems = true
	uespLog.savedVars.settings.data.isAutoMiningItems = uespLog.isAutoMiningItems
	uespLog.MsgColor(uespLog.mineColor, "Started auto-mining items at ID "..tostring(uespLog.mineItemsAutoNextItemId).." to "..tostring(uespLog.mineItemsAutoLastItemId))
	
	if (uespLog.mineItemOnlyLevel >= 0) then
		uespLog.MsgColor(uespLog.mineColor, ".     Only mining items with internal level of "..tostring(uespLog.mineItemOnlyLevel))
	end
	
	if (uespLog.mineItemOnlySubType >= 0) then
		uespLog.MsgColor(uespLog.mineColor, ".     Only mining items with internal type of "..tostring(uespLog.mineItemOnlySubType))
	end
	
	local text = uespLog.implodeKeys(uespLog.mineItemOnlyItemType, ", ")
	
	if (text ~= "") then
		uespLog.MsgColor(uespLog.mineColor, ".     Only mining items with item types of "..text)
	end
	
	zo_callLater(uespLog.MineItemsAutoLoopSafe, uespLog.MINEITEMS_AUTODELAY)
end


function uespLog.MineItemsAutoStartPotionData ()
	uespLog.isAutoMiningItems = true
	uespLog.savedVars.settings.data.isAutoMiningItems = uespLog.isAutoMiningItems
	uespLog.MsgColor(uespLog.mineColor, "Started auto-mining item potion data at effect index "..tostring(uespLog.mineItemPotionDataEffectIndex))
	
	zo_callLater(uespLog.MineItemsAutoLoopPotionData, uespLog.MINEITEMS_AUTODELAY)
end


function uespLog.MineItemsOutputStartLog ()
	local logData = { }
	
	logData = { }
	logData.itemId = uespLog.mineItemsAutoNextItemId
	logData.event = "mineItem::Start"
	logData.onlySubType = uespLog.mineItemOnlySubType
	logData.onlyLevel = uespLog.mineItemOnlyLevel
	logData.onlyItemType = uespLog.implodeKeys(uespLog.mineItemOnlyItemType, ", ")
	
	if (uespLog.mineItemPotionData) then
		logData.potionData = 1
	end
	
	uespLog.AppendDataToLog("all", logData, uespLog.GetTimeData())
	
	uespLog.mineItemAutoRestartOutputEnd = false
end


function uespLog.MineItemsOutputEndLog ()
	local logData = { }
	
	logData.itemId = uespLog.mineItemsAutoNextItemId
	logData.itemCount = uespLog.mineItemCount
	logData.badCount = uespLog.mineItemBadCount
	logData.event = "mineItem::End"
	uespLog.AppendDataToLog("all", logData, uespLog.GetTimeData())
	
	uespLog.mineItemAutoRestartOutputEnd = true
end


function uespLog.MineItemsAutoEnd ()
	local logData

	if (not uespLog.isAutoMiningItems) then
		return
	end
	
	uespLog.mineItemAutoReload = false
	uespLog.mineItemAutoRestart = false
	uespLog.savedVars.settings.data.mineItemAutoReload = false
	uespLog.savedVars.settings.data.mineItemAutoRestart = false
	uespLog.isAutoMiningItems = false
	uespLog.savedVars.settings.data.isAutoMiningItems = false
	
	if (not uespLog.mineItemAutoRestartOutputEnd) then
		uespLog.MineItemsOutputEndLog()
		uespLog.mineItemAutoRestartOutputEnd = true
	end
	
	if (uespLog.mineItemPotionData) then
		uespLog.MsgColor(uespLog.mineColor, "Stopped auto-mining potion data at effect index "..tostring(uespLog.mineItemPotionDataEffectIndex))	
	else
		uespLog.MsgColor(uespLog.mineColor, "Stopped auto-mining items at ID "..tostring(uespLog.mineItemsAutoNextItemId))
	end
	
	uespLog.MsgColor(uespLog.mineColor, "Total auto-mined "..tostring(uespLog.mineItemCount - uespLog.mineItemBadCount).." items, "..tostring(uespLog.mineItemBadCount).." bad")	
end


function uespLog.MineItemsCount ()
	local totalCount = 0

	for i, value in ipairs(uespLog.MINEITEM_LEVELS_SAFE) do
		local levelStart = value[1]
		local levelEnd = value[2]
		local qualityStart = value[3]
		local qualityEnd = value[4]
		local comment = value[5]
		
		local numLevels = levelEnd - levelStart + 1
		local numTypes = qualityEnd - qualityStart + 1
		
		totalCount = totalCount + numTypes * numLevels
	end
	
	uespLog.MsgColor(uespLog.mineColor, "Total mine item entries = "..tostring(#uespLog.MINEITEM_LEVELS_SAFE))
	uespLog.MsgColor(uespLog.mineColor, "Total level/subtype combinations = "..tostring(totalCount))
	uespLog.MsgColor(uespLog.mineColor, "Estimated item combinations = "..tostring(totalCount * uespLog.MINEITEM_ITEMCOUNTESTIMATE))
	
	totalCount = 0

	for i, value in ipairs(uespLog.MINEITEM_LEVELS_SHORT_SAFE) do
		local levelStart = value[1]
		local levelEnd = value[2]
		local qualityStart = value[3]
		local qualityEnd = value[4]
		local comment = value[5]
		
		local numLevels = levelEnd - levelStart + 1
		local numTypes = qualityEnd - qualityStart + 1
		
		totalCount = totalCount + numTypes * numLevels
	end
	
	uespLog.MsgColor(uespLog.mineColor, "Total mine item entries (short) = "..tostring(#uespLog.MINEITEM_LEVELS_SHORT_SAFE))
	uespLog.MsgColor(uespLog.mineColor, "Total level/subtype combinations (short) = "..tostring(totalCount))
	uespLog.MsgColor(uespLog.mineColor, "Estimated item combinations (short) = "..tostring(totalCount * uespLog.MINEITEM_ITEMCOUNTESTIMATE))
end


function uespLog.MineItemsAutoStatus ()

	uespLog.MsgColor(uespLog.mineColor, "Minimum reload delay when auto mining is "..tostring(uespLog.mineItemReloadDelay/1000).." sec")
	
	if (uespLog.isAutoMiningItems) then
		uespLog.MsgColor(uespLog.mineColor, "Currently auto-mining items.")
		uespLog.MsgColor(uespLog.mineColor, "Total auto-mined "..tostring(uespLog.mineItemCount - uespLog.mineItemBadCount).." items, "..tostring(uespLog.mineItemBadCount).." bad")	
		uespLog.MsgColor(uespLog.mineColor, "Auto-reload = "..tostring(uespLog.mineItemAutoReload)..",  auto-restart = "..tostring(uespLog.mineItemAutoRestart))	
	else
		uespLog.MsgColor(uespLog.mineColor, "Not currently auto-mining items.")
	end
	
	if (not uespLog.mineItemPotionData) then
		uespLog.MsgColor(uespLog.mineColor, "Next auto-mine itemId is "..tostring(uespLog.mineItemsAutoNextItemId))
	end
	
	if (uespLog.mineItemPotionData) then
		uespLog.MsgColor(uespLog.mineColor, "Mining item potion data.")
		uespLog.MsgColor(uespLog.mineColor, "Next potion effect index is "..tostring(uespLog.mineItemPotionDataEffectIndex))
	elseif (uespLog.mineItemOnlyLevel >= 0 and uespLog.mineItemOnlySubType >= 0) then
		uespLog.MsgColor(uespLog.mineColor, "Only mining items with internal level "..tostring(uespLog.mineItemOnlyLevel).." and internal type of "..tostring(uespLog.mineItemOnlySubType)..".")
	elseif (uespLog.mineItemOnlyLevel >= 0) then
		uespLog.MsgColor(uespLog.mineColor, "Only mining items with internal level "..tostring(uespLog.mineItemOnlyLevel)..".")
	elseif (uespLog.mineItemOnlySubType >= 0) then
		uespLog.MsgColor(uespLog.mineColor, "Only mining items with internal type of "..tostring(uespLog.mineItemOnlySubType)..".")
	end
	
	local text = uespLog.implodeKeys(uespLog.mineItemOnlyItemType, ", ")
	
	if (text ~= "") then
		uespLog.MsgColor(uespLog.mineColor, ".     Only mining items with item types of "..text)
	end
end


function uespLog.MineItemsQualityMapLogItem(itemLink, intLevel, intSubtype, extraData)
	local logData = { }
	local reqLevel = GetItemLinkRequiredLevel(itemLink)
	local reqCP = GetItemLinkRequiredChampionPoints(itemLink)
	local quality = GetItemLinkDisplayQuality(itemLink)
	
	logData.event = "mineItem::quality"
	logData.itemLink = itemLink
	logData.intLevel = intLevel
	logData.intSubtype = intSubtype
	logData.level = reqLevel
	logData.cp = reqCP
	logData.quality = quality
	logData.effLevel = reqLevel

	if (reqCp > 0) then
		logData.effLevel = 50 + math.floor(reqCp/10)
	end
	--logData.csv = tostring(intLevel) .. ", "..tostring(intSubtype)..", "..tostring(reqLevel)..", "..tostring(reqCP)..", "..tostring(quality)

	uespLog.AppendDataToLog("all", logData, extraData)
	
	local data = uespLog.savedVars.tempData.data
	data[#data+1] = tostring(intLevel) .. ","..tostring(intSubtype)..","..tostring(logData.effLevel)..","..tostring(quality)
end


function uespLog.MineItemsQualityMap(level)
	local extraData = uespLog.GetTimeData()
	level = level or 1
		
	uespLog.MsgColor(uespLog.mineColor, "Creating type quality map for item #"..tostring(uespLog.MINEITEM_QUALITYMAP_ITEMID).." at level "..tostring(level))
	
	for subtype = 0, 400 do
		local itemLink = uespLog.MakeItemLink(uespLog.MINEITEM_QUALITYMAP_ITEMID, level, subtype)
			
		if (uespLog.IsValidItemLink(itemLink)) then
			 uespLog.MineItemsQualityMapLogItem(itemLink, level, subtype, extraData)
		end
		
	end
	
end


function uespLog.MineItemsIdCheck(note)
	local itemId
	local logData = { }
	local extraData = uespLog.GetTimeData()
	
	if (uespLog.IsIdCheckInProgress) then
		uespLog.MsgColor(uespLog.mineColor, "ID Check is already in progress...")
		return false
	end

	uespLog.MsgColor(uespLog.mineColor, "Starting ID check of items...")
	
	logData.event = "mineItem::idCheck::start"
	logData.note = note or ""
	logData.apiVersion = GetAPIVersion()
	logData.gameVersion = _VERSION
	uespLog.AppendDataToLog("all", logData, extraData)
	
	uespLog.IdCheckRangeIdStart = -1
	uespLog.CurrentIdCheckItemId = 1
	uespLog.IdCheckValidCount = 0
	uespLog.IdCheckTotalCount = 0
	uespLog.IsIdCheckInProgress = true
	
	zo_callLater(uespLog.MineItemsIdCheckDoNext, uespLog.MINEITEM_IDCHECK_TIMEDELTA)
end


function uespLog.MineItemsIdCheckDoNext()
	local startId = uespLog.CurrentIdCheckItemId
	local endId = uespLog.CurrentIdCheckItemId + uespLog.MINEITEM_IDCHECK_NUMITEMS - 1
	local itemId
	local validCount = 0
	
	if (endId > uespLog.MINEITEM_AUTO_MAXITEMID) then
		endId = uespLog.MINEITEM_AUTO_MAXITEMID
	end

	for itemId = startId, endId do
		local itemLink = uespLog.MakeItemLink(itemId, 1, 1)
		uespLog.IdCheckTotalCount = uespLog.IdCheckTotalCount + 1
			
		if (uespLog.IsValidItemLink(itemLink)) then
			 uespLog.IdCheckValidCount = uespLog.IdCheckValidCount + 1
			 validCount = validCount + 1
			 
			if (uespLog.IdCheckRangeIdStart < 0) then
				uespLog.IdCheckRangeIdStart = itemId
			end
		elseif (uespLog.IdCheckRangeIdStart > 0) then
			uespLog.MineItemsLogValidIdRange(uespLog.IdCheckRangeIdStart, itemId-1)
			uespLog.IdCheckRangeIdStart = -1
		end
		
		uespLog.CurrentIdCheckItemId = itemId
	end
	
	uespLog.MsgColor(uespLog.mineColor,".     Item ID Check: "..tostring(startId).."-"..tostring(endId).." ("..tostring(validCount).." valid)")
	
	if (uespLog.CurrentIdCheckItemId < uespLog.MINEITEM_AUTO_MAXITEMID) then
		uespLog.CurrentIdCheckItemId = uespLog.CurrentIdCheckItemId + 1
		zo_callLater(uespLog.MineItemsIdCheckDoNext, uespLog.MINEITEM_IDCHECK_TIMEDELTA)
	else
		uespLog.MineItemsIdCheckEnd()
	end
	
end


function uespLog.MineItemsIdCheckEnd()

	if (uespLog.IdCheckRangeIdStart > 0) then
		uespLog.MineItemsLogValidIdRange(uespLog.IdCheckRangeIdStart, uespLog.CurrentIdCheckItemId-1)
		uespLog.IdCheckRangeIdStart = -1
	end
	
	logData = { }
	logData.event = "mineItem::idCheck::end"
	logData.validCount = uespLog.IdCheckValidCount
	logData.totalCount = uespLog.IdCheckTotalCount
	uespLog.AppendDataToLog("all", logData)
	
	uespLog.MsgColor(uespLog.mineColor, "Found "..tostring(uespLog.IdCheckValidCount).." valid items!")
	uespLog.IsIdCheckInProgress = false
end


function uespLog.MineItemsLogValidIdRange(startId, endId)
	local logData = { }
	
	logData.event = "mineItem::idCheck"
	logData.startId = startId
	logData.endId = endId
	
	uespLog.AppendDataToLog("all", logData, extraData)
end


SLASH_COMMANDS["/uespmineitems"] = function (cmd)
	local cmds = { }
	
	for word in cmd:gmatch("%S+") do table.insert(cmds, word) end
	
	local command = string.lower(cmds[1])
	
	if (command == "enable") then
		uespLog.MsgColor(uespLog.mineColor, "Enabled use of /uespmineitems (/umi)!")
		uespLog.MsgColor(uespLog.mineColorWarning, ".         WARNING -- This feature is experimental and can crash the")
		uespLog.MsgColor(uespLog.mineColorWarning, ".         ESO client! Use at your own risk....")
		uespLog.mineItemsEnabled = true
		uespLog.savedVars.settings.data.mineItemsEnabled = true
		return
	elseif (not uespLog.mineItemsEnabled) then
		uespLog.MsgColor(uespLog.mineColor, "Use of /uespmineitems (/umi) is currently disabled!")
		uespLog.MsgColor(uespLog.mineColor, ".         Enable with: /uespmineitems enable")
		return
	end
	
	if (not uespLog.IsLogData()) then
		uespLog.MsgColor(uespLog.mineColorWarning, "WARNING -- Logging is currently disabled. Enable with '/uesplog on'.")
	end
	
	if (command == "start" or command == "begin") then
		
		if (cmds[2] ~= nil) then
			if (uespLog.mineItemPotionData) then
				uespLog.mineItemPotionDataEffectIndex = tonumber(cmds[2])
				uespLog.mineItemPotionDataListIndex = 1
				uespLog.savedVars.settings.data.mineItemPotionDataEffectIndex = uespLog.mineItemPotionDataEffectIndex
			else
				uespLog.mineItemsAutoNextItemId = tonumber(cmds[2])
				uespLog.mineItemsAutoNextListIndex = 1
				uespLog.savedVars.settings.data.mineItemsAutoNextItemId = uespLog.mineItemsAutoNextItemId
				uespLog.savedVars.settings.data.mineItemsAutoNextListIndex = uespLog.mineItemsAutoNextListIndex
			end
		end
		
		uespLog.MineItemsAutoStart()
		return
	elseif (command == "reloaddelay" or command == "delay") then
		local delay = tonumber(cmds[2]) or -1
		
		if (delay <= 0) then
			uespLog.MsgColor(uespLog.mineColor, "Expecting a delay in seconds greater than zero!")
			uespLog.MsgColor(uespLog.mineColor, ".            /uespmineitems reloaddelay [seconds]")
			uespLog.MsgColor(uespLog.mineColor, "Current reload delay is "..tostring(uespLog.mineItemReloadDelay/1000).." sec")
			return
		end
		
		uespLog.savedVars.settings.data.mineItemReloadDelay = delay * 1000
		uespLog.mineItemReloadDelay = delay * 1000
		
		uespLog.MsgColor(uespLog.mineColor, "Set reload delay when auto mining items to "..tostring(delay).." sec")
		return
	elseif (command == "count") then
		uespLog.MineItemsCount()
		return
	elseif (command == "potion") then
		local option = string.lower(cmds[2])
		
		if (option == "on") then
			uespLog.mineItemPotionData = true
			uespLog.savedVars.settings.data.mineItemPotionData = true
		elseif (option == "off") then
			uespLog.mineItemPotionData = false
			uespLog.savedVars.settings.data.mineItemPotionData = false
		end
		
		if (uespLog.mineItemPotionData) then
			uespLog.MsgColor(uespLog.mineColor, "Mining potion data.")
		else
			uespLog.MsgColor(uespLog.mineColor, "Mining regular item data.")
		end
		
		return
	elseif (command == "subtype" or command == "type") then
		uespLog.mineItemOnlySubType = tonumber(cmds[2])
		if (uespLog.mineItemOnlySubType == nil) then uespLog.mineItemOnlySubType = -1 end
		uespLog.savedVars.settings.data.mineItemOnlySubType = uespLog.mineItemOnlySubType
		
		if (uespLog.mineItemOnlySubType < 0) then
			uespLog.MsgColor(uespLog.mineColor, "Mining items with all internal types.")
		else
			uespLog.MsgColor(uespLog.mineColor, "Only mining items with internal type of "..tostring(uespLog.mineItemOnlySubType)..".")
		end
		
		return
	elseif (command == "level") then
		uespLog.mineItemOnlyLevel = tonumber(cmds[2])
		if (uespLog.mineItemOnlyLevel == nil) then uespLog.mineItemOnlyLevel = -1 end
		uespLog.savedVars.settings.data.mineItemOnlyLevel = uespLog.mineItemOnlyLevel
		
		if (uespLog.mineItemOnlyLevel < 0) then
			uespLog.MsgColor(uespLog.mineColor, "Mining items with all internal levels.")
		else
			uespLog.MsgColor(uespLog.mineColor, "Only mining items with internal level of "..tostring(uespLog.mineItemOnlyLevel)..".")
		end
		
		return
	
	elseif (command == "itemtype") then
		uespLog.mineItemOnlyItemType = {}
	
		for i = 2, #cmds do
			local number = tonumber(cmds[i])
			
			if (number ~= nil and number >= 0) then
				uespLog.mineItemOnlyItemType[number] = 1
			end
		end
		
		uespLog.savedVars.settings.data.mineItemOnlyItemType = uespLog.mineItemOnlyItemType
		local text = uespLog.implodeKeys(uespLog.mineItemOnlyItemType, ", ")
		
		if (text == "") then
			uespLog.MsgColor(uespLog.mineColor, "Mining items with all item types.")
		else
			uespLog.MsgColor(uespLog.mineColor, "Only mining items with item types of "..text..".")
		end
		
		return
	
	elseif (command == "quick") then
		local option = string.lower(cmds[2])
		
		if (option == "on") then
			uespLog.savedVars.settings.data.mineItemOnlySubType = uespLog.MINEITEM_ONLYSUBTYPE
			uespLog.savedVars.settings.data.mineItemOnlyLevel = uespLog.MINEITEM_ONLYLEVEL
			uespLog.savedVars.settings.data.mineItemOnlyItemType = {}
			uespLog.MsgColor(uespLog.mineColor, "Only mining items with internal level "..tostring(uespLog.savedVars.settings.data.mineItemOnlyLevel).." and type "..tostring(uespLog.savedVars.settings.data.mineItemOnlySubType)..".")
		elseif (option == "off") then
			uespLog.MsgColor(uespLog.mineColor, "Mining items with all internal levels/types.")
		else
			uespLog.MsgColor(uespLog.mineColor, "Valid options for 'quick' are 'on'/'off'.")
		end
		
		return
	elseif (command == "end" or command == "stop") then
		uespLog.MineItemsAutoEnd()
		return
	elseif (command == "status") then
		uespLog.MineItemsAutoStatus()
		return
	elseif (command == "qualitymap") then
		uespLog.MineItemsQualityMap(1)
		uespLog.MineItemsQualityMap(50)
		return
	elseif (command == "enchantmap") then
		uespLog.MineEnchantCharges()
		return
	elseif (command == "idcheck") then
		uespLog.MineItemsIdCheck(cmds[2])
		return
	elseif (command == "autostart") then
		uespLog.mineItemAutoReload = true
		uespLog.mineItemAutoRestart = true
		uespLog.savedVars.settings.data.mineItemAutoReload = true
		uespLog.savedVars.settings.data.mineItemAutoRestart = true
		
		if (cmds[2] ~= nil) then
			if (uespLog.mineItemPotionData) then
				uespLog.mineItemPotionDataEffectIndex = tonumber(cmds[2])
				uespLog.mineItemPotionDataListIndex = 1
				uespLog.savedVars.settings.data.mineItemPotionDataEffectIndex = uespLog.mineItemPotionDataEffectIndex
			else
				uespLog.mineItemsAutoNextItemId = tonumber(cmds[2])
				uespLog.mineItemsAutoNextListIndex = 1
				uespLog.savedVars.settings.data.mineItemsAutoNextItemId = uespLog.mineItemsAutoNextItemId
				uespLog.savedVars.settings.data.mineItemsAutoNextListIndex = uespLog.mineItemsAutoNextListIndex
			end
		end
		
		if (cmds[3] ~= nil) then
			uespLog.mineItemsAutoLastItemId = tonumber(cmds[3])
			uespLog.savedVars.settings.data.mineItemsAutoLastItemId = uespLog.mineItemsAutoLastItemId
		else
			uespLog.mineItemsAutoLastItemId = uespLog.MINEITEM_AUTO_MAXITEMID
			uespLog.savedVars.settings.data.mineItemsAutoLastItemId = uespLog.mineItemsAutoLastItemId
		end
		
		uespLog.MsgColor(uespLog.mineColor, "Turned on item mining auto reload and restart!")
		uespLog.MsgColor(uespLog.mineColorWarning, ".   WARNING::This will reload the UI and clear log data automatically!")
		uespLog.MsgColor(uespLog.mineColorWarning, ".                      To stop use: /uespmineitem end")
		uespLog.MineItemsAutoStart()
		return
	end
	
	if (cmds[1] == nil) then 
		if (uespLog.mineItemPotionData) then
			cmds[1] = uespLog.mineItemPotionDataEffectIndex 
		else
			cmds[1] = uespLog.mineNextItemId 
		end
	end
	
	local startNumber = tonumber(cmds[1])
	
	if (startNumber == nil) then
		uespLog.MsgColor(uespLog.mineColor, "Invalid input to /uespmineitems (/umi)! Expected format is one of:")
		uespLog.MsgColor(uespLog.mineColor, ".              /uespmineitems [itemId]")
		uespLog.MsgColor(uespLog.mineColor, ".              /uespmineitems status")
		uespLog.MsgColor(uespLog.mineColor, ".              /uespmineitems start [startId]")
		uespLog.MsgColor(uespLog.mineColor, ".              /uespmineitems stop")
		uespLog.MsgColor(uespLog.mineColor, ".              /uespmineitems autostart [startId]")
		uespLog.MsgColor(uespLog.mineColor, ".              /uespmineitems qualitymap")
		uespLog.MsgColor(uespLog.mineColor, ".              /uespmineitems enchantmap")
		uespLog.MsgColor(uespLog.mineColor, ".              /uespmineitems subtype [subType]")
		uespLog.MsgColor(uespLog.mineColor, ".              /uespmineitems idcheck [note]")
		uespLog.MsgColor(uespLog.mineColor, ".              /uespmineitems quick [on/off]")
		uespLog.MsgColor(uespLog.mineColor, ".              /uespmineitems potion [on/off]")
		uespLog.MsgColor(uespLog.mineColor, ".              /uespmineitems reloaddelay [number]")
		uespLog.MsgColor(uespLog.mineColor, ".              /uespmineitems level [#]")
		uespLog.MsgColor(uespLog.mineColor, ".              /uespmineitems subtype [#]")
		uespLog.MsgColor(uespLog.mineColor, ".              /uespmineitems itemtype [#] [#] ...")
		
		return
	end
	
	if (uespLog.mineItemPotionData) then
		uespLog.MineItemIteratePotionData(uespLog.mineItemPotionDataEffectIndex, uespLog.MINEITEM_POTION_ITEMID, uespLog.MINEITEM_POTION_MAGICITEMID)
		uespLog.MineItemIteratePotionData(uespLog.mineItemPotionDataEffectIndex, uespLog.MINEITEM_POISON_ITEMID, uespLog.MINEITEM_POISON_MAGICITEMID)
	else
		uespLog.MsgColor(uespLog.mineColor, "Trying to mine items with ID "..tostring(startNumber))
		uespLog.MineItems(startNumber, startNumber)
	end
end


function uespLog.ClearAllSavedVarSections()

	for key, value in pairs(uespLog.savedVars) do
	
		if (key == "settings" or key == "info" or key == "charInfo") then
			-- Keep data
		elseif (key == "globals" or key == "all" or key == "buildData" or key == "charData" or key == "bankData" or key == "tempData" or key == "skillCoef" or key == "craftBagData") then
			uespLog.savedVars[key].data = { }
			uespLog.savedVars[key].version = uespLog.DATA_VERSION
		else
			uespLog.savedVars[key] = nil
		end
	end

end


function uespLog.ClearRootSavedVar()
	
	for key1, value1 in pairs(uespLogSavedVars) do  	-- Default
		for key2, value2 in pairs(value1) do			-- @User
			for key3, value3 in pairs(value2) do		-- $AccountWide
				for key4, value4 in pairs(value3) do	-- globals, all, info, settings, ....
					uespLog.DebugExtraMsg("Clearing saved data section "..tostring(key4))
					
					if (key4 == "settings" or key4 == "info" or key4 == "charInfo") then
						-- Keep data
					elseif (key4 == "globals" or key4 == "all" or key4 == "buildData" or key4 == "charData" or key4 == "bankData" or key4 == "tempData" or key4 == "skillCoef" or key4 == "craftBagData") then
						uespLogSavedVars[key1][key2][key3][key4].data = { }
						uespLogSavedVars[key1][key2][key3][key4].version = uespLog.DATA_VERSION
					else
						uespLogSavedVars[key1][key2][key3][key4] = nil  -- Delete unknown section
					end
			
				end
			end
		end
	end
	
end


SLASH_COMMANDS["/uespreset"] = function (cmd)
	cmd = cmd:lower()
	
	if (cmd == "all") then
		uespLog.ClearSavedVarSection("all")
		uespLog.ClearSavedVarSection("globals")
		uespLog.SetTotalInspiration(0)
		uespLog.ClearAllSavedVarSections()
		uespLog.ClearRootSavedVar()
		uespLog.ClearBuildData()
		uespLog.ClearCharData()
		uespLog.InitializeTrackLootData(true)
		uespLog.SkillCoefResetSkillList()
		uespLog.Msg("Reset all logged data")
	elseif (cmd == "builddata" or cmd == "build" ) then
		uespLog.ClearBuildData()
	elseif (cmd == "chardata" or cmd == "char") then
		uespLog.ClearCharData()
	elseif (cmd == "log") then
		uespLog.ClearSavedVarSection("all")
		uespLog.Msg("Reset regular logged data")
	elseif (cmd == "temp" or cmd == "tempdata") then
		uespLog.ClearSavedVarSection("tempData")
		uespLog.Msg("Reset temporary logged data")
	elseif (cmd == "globals" or cmd == "global") then
		uespLog.ClearSavedVarSection("globals")
		uespLog.Msg("Reset logged global data")
	elseif (cmd == "skillcoef") then
		uespLog.ClearSkillCoefData()
		uespLog.Msg("Cleared all skill coefficient data.")
	elseif (cmd == "inspiration") then
		uespLog.SetTotalInspiration(0)
		uespLog.Msg("Reset crafting inspiration total")
	elseif (cmd == "lootdata" or cmd == "trackloot" or cmd == "loot") then
		uespLog.InitializeTrackLootData(true)
		uespLog.Msg("Reset loot tracking data!")
	else
		uespLog.Msg("Expected command format is one of")
		uespLog.Msg(".       /uespreset log                         Collected log information")
		uespLog.Msg(".       /uespreset build                  Saved build data")
		uespLog.Msg(".       /uespreset char                   Character data")
		uespLog.Msg(".       /uespreset temp                      Temporary data")
		uespLog.Msg(".       /uespreset globals                  Mined globals data")
		uespLog.Msg(".       /uespreset achievements       Mined achievement data")
		uespLog.Msg(".       /uespreset inspiration             Set crafting inspiration to 0")
		uespLog.Msg(".       /uespreset skillcoef             Clear all skill coefficient data")
		uespLog.Msg(".       /uespreset loot                    Clear all loot tracking data")
		uespLog.Msg(".       /uespreset all                          All saved data")		
	end

end


SLASH_COMMANDS["/uesptargetinfo"] = function (cmd)
	uespLog.ShowTargetInfo()
end


function uespLog.GetCraftingName(craftingType)

	if (craftingType == CRAFTING_TYPE_ALCHEMY) then return "Alchemy" end
	if (craftingType == CRAFTING_TYPE_BLACKSMITHING) then return "Blacksmithing" end
	if (craftingType == CRAFTING_TYPE_CLOTHIER) then return "Clothier" end
	if (craftingType == CRAFTING_TYPE_ENCHANTING) then return "Enchanting" end
	if (craftingType == CRAFTING_TYPE_INVALID) then return "Invalid" end
	if (craftingType == CRAFTING_TYPE_PROVISIONING) then return "Provisioning" end
	if (craftingType == CRAFTING_TYPE_WOODWORKING) then return "Woodworking" end
	if (craftingType == CRAFTING_TYPE_JEWELRYCRAFTING) then return "Jewelry" end
	
	return "Unknown"
end


function uespLog.GetShortCraftingName(craftingType)

	if (craftingType == CRAFTING_TYPE_ALCHEMY) then return "AL" end
	if (craftingType == CRAFTING_TYPE_BLACKSMITHING) then return "BS" end
	if (craftingType == CRAFTING_TYPE_CLOTHIER) then return "CL" end
	if (craftingType == CRAFTING_TYPE_ENCHANTING) then return "EN" end
	if (craftingType == CRAFTING_TYPE_INVALID) then return "IN" end
	if (craftingType == CRAFTING_TYPE_PROVISIONING) then return "PV" end
	if (craftingType == CRAFTING_TYPE_WOODWORKING) then return "WW" end
	if (craftingType == CRAFTING_TYPE_JEWELRYCRAFTING) then return "JY" end
	
	return "??"
end


function uespLog.GetItemTraitName (traitType)
	return GetString(SI_ITEMTRAITTYPE0 + traitType)
end


function uespLog.ShowResearchInfo (craftingType)
	local TradeskillName = uespLog.GetCraftingName(craftingType)
	local numLines = GetNumSmithingResearchLines(craftingType)
	local maxSimultaneousResearch = GetMaxSimultaneousSmithingResearch(craftingType)
	local researchCount = 0
	
	if (numLines == 0 or maxSimultaneousResearch == 0) then
		uespLog.MsgColor(uespLog.researchColor, ""..TradeskillName.." doesn't have any research lines available!")
		return
	end
	
	for researchLineIndex = 1, numLines do
		local name, icon, numTraits, timeRequiredForNextResearchSecs = GetSmithingResearchLineInfo(craftingType, researchLineIndex)
		
		for traitIndex = 1, numTraits do
			local duration, timeRemainingSecs = GetSmithingResearchLineTraitTimes(craftingType, researchLineIndex, traitIndex)
			local traitType, traitDescription, known = GetSmithingResearchLineTraitInfo(craftingType, researchLineIndex, traitIndex)
			local traitName = uespLog.GetItemTraitName(traitType)
			
			if (duration ~= nil) then
				local days = math.floor(timeRemainingSecs / 3600 / 24)
				local hours = math.floor(timeRemainingSecs / 3600) % 24
				local minutes = math.floor(timeRemainingSecs / 60) % 60
				local seconds = timeRemainingSecs % 60
				local timeFmt = ""
				
				if (days > 1) then
					timeFmt = string.format("%d days %02d:%02d:%02d", days, hours, minutes, seconds)
				elseif (days > 0) then
					timeFmt = string.format("%d day %02d:%02d:%02d", days, hours, minutes, seconds)
				else
					timeFmt = string.format("%02d:%02d:%02d", hours, minutes, seconds)
				end
				
				--uespLog.Msg(""..tostring(TradeskillName).." line for "..tostring(name).." ("..tostring(traitName)..") has "..timeFmt.." left on research.")
				uespLog.MsgColor(uespLog.researchColor, ""..tostring(TradeskillName).." "..tostring(name).." ("..tostring(traitName)..") has "..timeFmt.." left.")
				researchCount = researchCount + 1
			end
		end
	end
	
	if (researchCount < maxSimultaneousResearch) then
		local slotsOpen = maxSimultaneousResearch - researchCount
		uespLog.MsgColor(uespLog.researchColor, ""..TradeskillName.." has "..tostring(slotsOpen).." research slots available.")
	end

end


SLASH_COMMANDS["/uesptestpotion"] = function (cmd)
	local cmds = { }
	for word in cmd:gmatch("%S+") do table.insert(cmds, word) end
	
	local itemLink = uespLog.MakeItemLinkEx( { itemId = cmds[3] or 54339, level = cmds[1] or 1, quality = cmds[2] or 1, potionEffect = cmds[4] or 8454917 } )
	uespLog.Msg("UESP: Make test link ".. itemLink)
	ZO_PopupTooltip_SetLink(itemLink)
end


SLASH_COMMANDS["/uesptest"] = function (cmd)
	--uespLog.DebugMsg("Showing Test Time (noon)....")
	--uespLog.ShowTime(1398882554)	-- 1398882554 = 14:30 April 30th 2014 which should be exactly noon in game time 
	--uespLog.DebugMsg("Showing Test Time (sunset)....")
	--uespLog.ShowTime(1398889754)   -- 1308889754 = 16:32 April 30th 2014 which should be sunset
	--uespLog.DebugMsg("Showing Test Time (almost new moon)....")
	--uespLog.ShowTime(1399083327)   -- 1399083327 = Wanning crescent moon, almost new, 0.97
	--uespLog.DebugMsg("Showing Test Time (noon)....")
	--uespLog.ShowTime(1399133861)   -- 1399133861 = 12:20 3 May 2014, noon in-game
	--uespLog.DebugMsg("Showing Test Time (midnight)....")
	--uespLog.ShowTime(1399753920)   -- 1399753920 = 16:35 10 May 2014, should be midnight in game with a wanning crescent moon (0.875)
	-- Moon Phase ~ Full Moon, TimeStamp = 1435838770, LocalTime = 124897, 2 July 2015 08:11
	-- Moon Phase ~ Full Moon, TimeStamp = 1438352285 (14:20 31 July 2015)
	-- Moon Phase ~ Slightly Waxing Gibbous past First Quarter (0.3-0.35), TimeStamp = 1440087745 (12:26 20 Aug 2015)
		
	uespLog.DebugMsg("Showing Test Time (1425169441)....")
	uespLog.ShowTime(1425169441)
	
	uespLog.DebugMsg("Showing Test Time (1395696240)....")
	uespLog.ShowTime(1395696240)
	
	uespLog.DebugMsg("Showing Test Time (almost new moon, 0.97)....")
	uespLog.ShowTime(1399083327)
	
	uespLog.DebugMsg("Showing Test Time (Wanning Crescent, 0.875)....")
	uespLog.ShowTime(1399753920)

	uespLog.DebugMsg("Showing Test Time (Full Moon, 0.5)....")
	uespLog.ShowTime(1435838770)
	
	uespLog.DebugMsg("Showing Test Time (Full Moon, 0.5)....")
	uespLog.ShowTime(1438352285)
	
	uespLog.DebugMsg("Showing Test Time (Waxing Gibbous Moon, 0.33)....")
	uespLog.ShowTime(1440087745)	
	
	uespLog.DebugMsg("Showing Test Time (Full Moon, 0.5)....")
	uespLog.ShowTime(1459099163)	
	
	--23260393 / 20955 = 1110 = 37
	--2513515 / 20955 = 119 / 30 = 3.96
	--60015836 (0.5) / 20955 = 2864 / 30 = 95.456
end


SLASH_COMMANDS["/uespresearch"] = function (cmd)
	local cmds, firstCmd = uespLog.SplitCommands(cmd)
	
	if (firstCmd == "includeset" or firstCmd == "includesets") then
		local value = string.lower(cmds[2])

		if (value == "on") then
			uespLog.SetIncludeSetItemsForTraitResearch(true)
		elseif (value == "off") then
			uespLog.SetIncludeSetItemsForTraitResearch(false)
		else
			uespLog.Msg("Current include sets for research items is "..uespLog.BoolToOnOff(uespLog.GetIncludeSetItemsForTraitResearch())..".")
			return
		end
		
		uespLog.Msg("Set include sets for research items to "..uespLog.BoolToOnOff(uespLog.GetIncludeSetItemsForTraitResearch())..".")

		return
	elseif (firstCmd == "maxquality") then
		local quality = tonumber(cmds[2])
		
		if (quality >= 0 and quality <= 5) then
			uespLog.SetMaxQualityForTraitResearch(quality)
		elseif (string.lower(cmds[2]) == "off") then
			uespLog.SetMaxQualityForTraitResearch(0)
		elseif (cmds[2] == nil) then
			uespLog.Msg("Current max item quality for research items is "..uespLog.GetMaxQualityForTraitResearch()..".")
			return
		else
			uespLog.Msg("Invalid quality value! Expected a number from 0 to 5.")
			return
		end
		
		uespLog.Msg("Set max quality of research items to "..uespLog.GetMaxQualityForTraitResearch()..".")
		return
	elseif (firstCmd == "help") then
		uespLog.Msg("Shows and sets smithing research information:")
		uespLog.Msg(".     /uespresearch                                   Show all current research")
		uespLog.Msg(".     /uespresearch includesets [on||off]   Include set items in research")
		uespLog.Msg(".     /uespresearch maxquality [0-5]       Set max quality of items to research")
		uespLog.Msg(".     /uri                                                   Short command version")
		return
	end
	
	uespLog.ShowResearchInfo(CRAFTING_TYPE_CLOTHIER)
	uespLog.ShowResearchInfo(CRAFTING_TYPE_BLACKSMITHING)
	uespLog.ShowResearchInfo(CRAFTING_TYPE_JEWELRYCRAFTING)
	uespLog.ShowResearchInfo(CRAFTING_TYPE_WOODWORKING)	
end


uespLog.CRAFTSTYLENAME_TO_ITEMSTYLE = {
	["mercenary"] = 26,
	["breton"] = 1,
	["dwemer"] = 14,
	["ancient elf"] = 15,
	["ancient_elf"] = 15,
	["imperial"] = 16,
	["barbaric"] = 17,
	["primal"] = 19,
	["redguard"] = 2,
	["daedric"] = 20,
	["ancient orc"] = 22,
	["ancient_orc"] = 22,
	["glass"] = 28,
	["xivkyn"] = 29,
	["akaviri"] = 33,
	["dunmer"] = 4,
	["dark elf"] = 4,
	["dark_elf"] = 4,
	["nord"] = 5,
	["argonian"] = 6,
	["altmer"] = 7,
	["high elf"] = 7,
	["high_elf"] = 7,
	["bosmer"] = 8,
	["wood elf"] = 8,
	["wood_elf"] = 8,
	["khajiit"] = 9,
	["orc"] = 3,
		
			-- Thieves Guild
	["outlaw"] = 47,
	["malacath"] = 13,
	["trinimac"] = 21,
	["soul-shriven"] = 30,
	["soulshriven"] = 30,
	["soul shriven"] = 30,
	["soul_shriven"] = 30,
	["soul"] = 30,
	["daggerfall"] = 23,
	["daggerfall covenant"] = 23,
	["daggerfall_covenant"] = 23,
	["covenant"] = 23,
	["ebonheart"] = 24,
	["ebonheart pact"] = 24,
	["ebonheart_pact"] = 24,
	["pact"] = 24,
	["aldmeri"] = 25,
	["aldmeri dominion"] = 25,
	["aldmeri_dominion"] = 25,
	["dominion"] = 25,
	
			-- Dark Brotherhood
	["assassin"] = ITEMSTYLE_ORG_ASSASSINS,
	["assassins"] = ITEMSTYLE_ORG_ASSASSINS,
	["assassins league"] = ITEMSTYLE_ORG_ASSASSINS,
	["assassins_league"] = ITEMSTYLE_ORG_ASSASSINS,
	["thieves guild"] = ITEMSTYLE_ORG_THIEVES_GUILD,
	["thieves_guild"] = ITEMSTYLE_ORG_THIEVES_GUILD,
	["thieves"] = ITEMSTYLE_ORG_THIEVES_GUILD,
	["thieve"] = ITEMSTYLE_ORG_THIEVES_GUILD,
	["thief"] = ITEMSTYLE_ORG_THIEVES_GUILD,
	["tg"] = ITEMSTYLE_ORG_THIEVES_GUILD,
	["abahs watch"] = ITEMSTYLE_ORG_ABAHS_WATCH,
	["abah's watch"] = ITEMSTYLE_ORG_ABAHS_WATCH,
	["abahs_watch"] = ITEMSTYLE_ORG_ABAHS_WATCH,
	["abahs"] = ITEMSTYLE_ORG_ABAHS_WATCH,
	["abah"] = ITEMSTYLE_ORG_ABAHS_WATCH,
	
		-- Shadows of the Hist
	["akatosh"] = 16,
	["order of the hour"] = 16,
	["order_of_the_hour"] = 16,
	["order"] = 16,
	["dark brotherhood"] = 12,
	["dark_brotherhood"] = 12,
	["dark"] = 12,
	["db"] = 12,
	["dro-m'athra"] = 45,
	["dro m athra"] = 45,
	["dromathra"] = 45,
	["dro_mathra"] = 45,
	["dro"] = 45,
	["minotaur"] = 39,
	["mino"] = 39,
	
		-- Witches Festival
	["grim arlequin"] = 58,
	["grim_arlequin"] = 58,
	["grim harlequin"] = 58,
	["grim_harlequin"] = 58,
	["grim"] = 58,
	["hollowjack"] = 59,
	["hollow"] = 59,
	
		-- One Tamriel
	["yokudan"] = 35,
	["celestial"] = 27,
	["draugr"] = 31,
	
		-- New Life Festival
	["skinchanger"] = 42,
	["skin"] = 42,
	["stalhrim frostcaster"] = 53,
	["stalhrim"] = 53,
	["stal"] = 53,
	["frostcaster"] = 53,
	["frost"] = 53,
	
		-- Homestead
	["silken ring"] = 56,
	["silken_ring"] = 56,
	["silkenring"] = 56,
	["silken"] = 56,
	["mazzatun"] = 57,
	["ra gada"] = 44,
	["ra_gada"] = 44,
	["ragada"] = 44,
	["ebony"] = 40,
	
		-- Morrowind
	["ashlander"] = 54,
	["ash"] = 54,
	["militant ordinator"] = 50,
	["militant_ordinator"] = 50,
	["militantordinator"] = 50,
	["ordinator"] = 50,
	["militant"] = 50,
	["morag tong"] = 43,
	["morag_tong"] = 43,
	["moragtong"] = 43,
	["morag"] = 43,
	["buoyant armiger"] = 52,
	["buoyant_armiger"] = 52,
	["buoyantarmiger"] = 52,
	["armiger"] = 52,
	["buoyant"] = 52,
	
		-- Horns of the Reach
	["redoran"] = 48,
	["hlaalu"] = 49,
	["telvanni"] = 51,
	
		-- Clockwork City
	["bloodforge"] = 61,
	["dreadhorn"] = 62,
	["apostle"] = 65,
	["ebonshadow"] = 66,
	
		-- Dragon Bones
	['worm cult'] = 55,
	['wormcult'] = 55,
	['worm'] = 55,
	
		-- Summerset
	['fang lair'] = 69,
	['fang_lair'] = 69,
	['fanglair'] = 69,
	['scalecaller'] = 70,
	['psijic order'] = 71,
	['psijic_order'] = 71,
	['psijicorder'] = 71,
	['psijic'] = 71,
	['sapiarch'] = 72,
	['welkynar'] = 73,
	['dremora'] = 74,
	['pyandonean'] = 75,
	['maormer'] = 75,
	
		-- Wolfhunter
	['welkynar'] = 73,
	
		-- Murkmire
	['huntsman'] = 77,
	['silver dawn'] = 78,
	['silver_dawn'] = 78,
	['silverdawn'] = 78,
	['dead-water'] = 79,
	['deadwater'] = 79,
	['elder argonian'] = 81,
	['elder_argonian'] = 81,
	['elderargonian'] = 81,
	
		-- Wrathstone
	['honor guard'] = 80,
	['honor_guard'] = 80,
	['honorguard'] = 80,
	['honor'] = 80,
	
		-- Elsweyr
	['coldsnap'] = 82,
	['meridian'] = 83,
	['anequina'] = 84,
	['pellitine'] = 85,
		
		-- Dragonhold
	['sunspire'] = 86,
	['dragon bone'] = 87,
	['dragon_bone'] = 87,
	['dragonbone'] = 87,
	["stags of z'en"] = 89,
	["stags_of_z'en"] = 89,
	["stagsofz'en"] = 89,
	["stagsofzen"] = 89,
	['dragonguard'] = 92,
	['moongrave fane'] = 93,
	['moongrave_fane'] = 93,
	['moongravefane'] = 93,
	['moongrave'] = 93,
	['new moon priest'] = 94,
	['new_moon_priest'] = 94,
	['newmoonpriest'] = 94,
	['newmoon'] = 94,
	['shield of senchal'] = 95,
	['shield_of_senchal'] = 95,
	['shieldofsenchal'] = 95,
	['senchal'] = 95,
	
		-- Greymoore
	['icereach coven'] = 97,
	['icereach_coven'] = 97,
	['icereachcoven'] = 97,
	['pyre watch'] = 98,
	['pyre_watch'] = 98,
	['pyrewatch'] = 98,
	['swordthane'] = 99,
	['blackreach vanguard'] = 100,
	['blackreach_vanguard'] = 100,
	['blackreachvanguard'] = 100,
	['blackreach'] = 100,
	['greymoore'] = 101,
	['sea giant'] = 102,	
	['sea_giant'] = 102,
	['seagiant'] = 102,
	['ancestral nord'] = 103,
	['ancestral_nord'] = 103,
	['ancestralnord'] = 103,
	['ancestral high elf'] = 104,
	['ancestral_high_elf'] = 104,
	['ancestralhighelf'] = 104,
	['ancestral orc'] = 105,
	['ancestral_orc'] = 105,
	['ancestralorc'] = 105,
	
	-- Stonethorn
	['thorn legion'] = 106,
	['thorn_legion'] = 106,
	['thornlegion'] = 106,
	['hazardous alchemy'] = 107,
	['hazardous_alchemy'] = 107,
	['hazardousalchemy'] = 107,
	['hazardous'] = 107,
	
	-- Flames of Ambition
	['ancestral reach'] = 110,
	['ancestral_reach'] = 110,
	['ancestralreach'] = 110,
	['night hollow'] = 111,
	['night_hollow'] = 111,
	['nighthollow'] = 111,
	['arkthzand armory'] = 112,
	['arkthzand_armory'] = 112,
	['arkthzandarmory'] = 112,
	['arkthzand'] = 112,
	['wayward guardian'] = 113,
	['wayward_guardian'] = 113,
	['waywardguardian'] = 113,
	['wayward'] = 113,
	
}


uespLog.CRAFTSTYLENAME_TO_MOTIFID = {
	["mercenary"] = { 64716, 64717, 64718, 64719, 64720, 64721, 64722, 64723, 64723, 64725, 64726, 64727, 64728, 64729  }, --64715, 64730
	["breton"] = 16425,
	["dwemer"] = { 57573, 57574, 57575, 57576, 57577, 57578, 57579, 57580, 57581, 57582, 57583, 57584, 57585, 57586 }, -- 57572, 
	["ancient elf"] = 51638,
	["ancient_elf"] = 51638,
	["imperial"] = 54868,
	["barbaric"] = 51565,
	["primal"] = 51345,
	["redguard"] = 16427,
	["daedric"] = 51688,
	["ancient orc"] = { 69528, 69529, 69530, 69531, 69532, 69533, 69534, 69535, 69536, 69537, 69538, 69539, 69540, 69541 }, -- 69527, 69542
	["ancient_orc"] = { 69528, 69529, 69530, 69531, 69532, 69533, 69534, 69535, 69536, 69537, 69538, 69539, 69540, 69541 }, -- 69527, 69542
	["glass"] = { 64670, 64671, 64672, 64673, 64674, 64675, 64676, 64677, 64678, 64679, 64680, 64681, 64682, 64683 }, -- 64669, 64684
	["yokudan"] = { 57606, 57607, 57608, 57609, 57610, 57611, 57612, 57613, 57614, 57615, 57616, 57617, 57618, 57619 }, -- 57605
	["xivkyn"] = { 57835, 57836, 57837, 57838, 57839, 57840, 57841, 57842, 57843, 57844, 57845, 57846, 57847, 57848  }, -- 57834
	["akaviri"] = { 57591, 57592, 57593, 57594, 57595, 57596, 57597, 57598, 57599, 57600, 57601, 57602, 57603, 57604 }, -- 57590
	["dunmer"] = 27245,
	["dark elf"] = 27245,
	["dark_elf"] = 27245,
	["nord"] = 27244,
	["argonian"] = 27246,
	["altmer"] = 16424,
	["high elf"] = 16424,
	["high_elf"] = 16424,
	["bosmer"] = 16428,
	["wood elf"] = 16428,
	["wood_elf"] = 16428,
	["khajiit"] = 44698,
	["orc"] = 16426,
	
			-- Thieves Guild
	["outlaw"] = { 71523, 71524, 71525, 71526, 71527, 71528, 71529, 71530, 71531, 71532, 71533, 71534, 71535, 71536 }, -- 71522, 71537
	["malacath"] = { 71567, 71568, 71569, 71570, 71571, 71572, 71573, 71574, 71575, 71576, 71577, 71578, 71579, 71580 }, -- 71566, 71581
	["trinimac"] = { 71551, 71552, 71553, 71554, 71555, 71556, 71557, 71558, 71559, 71560, 71561, 71562, 71563, 71564 }, -- 71550, 71565
	["soul-shriven"] = 71765,
	["soulshriven"]  = 71765,
	["soul shriven"] = 71765,
	["soul_shriven"] = 71765,
	["soul"] = 71765,
	["daggerfall"]          = { 71705, 71706, 71707, 71708, 71709, 71710, 71711, 71712, 71713, 71714, 71715, 71716, 71717, 71718 }, -- 71704, 71719
	["daggerfall covenant"] = { 71705, 71706, 71707, 71708, 71709, 71710, 71711, 71712, 71713, 71714, 71715, 71716, 71717, 71718 }, -- 71704, 71719
	["daggerfall_covenant"] = { 71705, 71706, 71707, 71708, 71709, 71710, 71711, 71712, 71713, 71714, 71715, 71716, 71717, 71718 }, -- 71704, 71719
	["covenant"]            = { 71705, 71706, 71707, 71708, 71709, 71710, 71711, 71712, 71713, 71714, 71715, 71716, 71717, 71718 }, -- 71704, 71719
	["ebonheart"]      = { 71721, 71722, 71723, 71724, 71725, 71726, 71727, 71728, 71729, 71730, 71731, 71732, 71733, 71734 }, -- 71720, 71735
	["ebonheart pact"] = { 71721, 71722, 71723, 71724, 71725, 71726, 71727, 71728, 71729, 71730, 71731, 71732, 71733, 71734 }, -- 71720, 71735
	["ebonheart_pact"] = { 71721, 71722, 71723, 71724, 71725, 71726, 71727, 71728, 71729, 71730, 71731, 71732, 71733, 71734 }, -- 71720, 71735
	["pact"]           = { 71721, 71722, 71723, 71724, 71725, 71726, 71727, 71728, 71729, 71730, 71731, 71732, 71733, 71734 }, -- 71720, 71735
	["aldmeri"]          = { 71689, 71690, 71691, 71692, 71693, 71694, 71695, 71696, 71697, 71698, 71699, 71700, 71701, 71702 }, -- 71688, 71703
	["aldmeri dominion"] = { 71689, 71690, 71691, 71692, 71693, 71694, 71695, 71696, 71697, 71698, 71699, 71700, 71701, 71702 }, -- 71688, 71703
	["aldmeri_dominion"] = { 71689, 71690, 71691, 71692, 71693, 71694, 71695, 71696, 71697, 71698, 71699, 71700, 71701, 71702 }, -- 71688, 71703
	["dominion"]          = { 71689, 71690, 71691, 71692, 71693, 71694, 71695, 71696, 71697, 71698, 71699, 71700, 71701, 71702 }, -- 71688, 71703
	
		-- Dark Brotherhood
	["assassin"]      = {76879, 76880, 76881, 76882, 76883, 76884, 76885, 76886, 76887, 76888, 76889, 76890, 76891, 76892}, -- 76878, 76893
	["assassins"]      = {76879, 76880, 76881, 76882, 76883, 76884, 76885, 76886, 76887, 76888, 76889, 76890, 76891, 76892}, -- 76878, 76893
	["assassins league"] = {76879, 76880, 76881, 76882, 76883, 76884, 76885, 76886, 76887, 76888, 76889, 76890, 76891, 76892}, -- 76878, 76893
	["assassins_league"] = {76879, 76880, 76881, 76882, 76883, 76884, 76885, 76886, 76887, 76888, 76889, 76890, 76891, 76892}, -- 76878, 76893
	["thieves guild"] = {74556, 74557, 74558, 74559, 74560, 74561, 74562, 74563, 74564, 74565, 74566, 74567, 74568, 74569}, -- 74555, 74570
	["thieves_guild"] = {74556, 74557, 74558, 74559, 74560, 74561, 74562, 74563, 74564, 74565, 74566, 74567, 74568, 74569}, -- 74555, 74570
	["thieves"] 	  = {74556, 74557, 74558, 74559, 74560, 74561, 74562, 74563, 74564, 74565, 74566, 74567, 74568, 74569}, -- 74555, 74570
	["thieve"] 	      = {74556, 74557, 74558, 74559, 74560, 74561, 74562, 74563, 74564, 74565, 74566, 74567, 74568, 74569}, -- 74555, 74570
	["thief"]         = {74556, 74557, 74558, 74559, 74560, 74561, 74562, 74563, 74564, 74565, 74566, 74567, 74568, 74569}, -- 74555, 74570
	["tg"]            = {74556, 74557, 74558, 74559, 74560, 74561, 74562, 74563, 74564, 74565, 74566, 74567, 74568, 74569}, -- 74555, 74570
	["abahs watch"]   = {74540, 74541, 74542, 74543, 74544, 74545, 74546, 74547, 74548, 74549, 74550, 74551, 74552, 74553}, -- 74539, 74554
	["abah's watch"]   = {74540, 74541, 74542, 74543, 74544, 74545, 74546, 74547, 74548, 74549, 74550, 74551, 74552, 74553}, -- 74539, 74554
	["abahs_watch"]   = {74540, 74541, 74542, 74543, 74544, 74545, 74546, 74547, 74548, 74549, 74550, 74551, 74552, 74553}, -- 74539, 74554
	["abahs"]         =	{74540, 74541, 74542, 74543, 74544, 74545, 74546, 74547, 74548, 74549, 74550, 74551, 74552, 74553}, -- 74539, 74554
	["abah"]          = {74540, 74541, 74542, 74543, 74544, 74545, 74546, 74547, 74548, 74549, 74550, 74551, 74552, 74553}, -- 74539, 74554
	
		-- Shadows of the Hist
	["akatosh"] = { 82088, 82089, 82090, 82091, 82092, 82093, 82094, 82095, 82096, 82097, 82098, 82099, 82100, 82101 }, -- 82087, 82102 
	["order of the hour"] = { 82088, 82089, 82090, 82091, 82092, 82093, 82094, 82095, 82096, 82097, 82098, 82099, 82100, 82101 }, -- 82087, 82102 
	["order_of_the_hour"] = { 82088, 82089, 82090, 82091, 82092, 82093, 82094, 82095, 82096, 82097, 82098, 82099, 82100, 82101 }, -- 82087, 82102 
	["order"] = { 82088, 82089, 82090, 82091, 82092, 82093, 82094, 82095, 82096, 82097, 82098, 82099, 82100, 82101 }, -- 82087, 82102 
	
	["dark brotherhood"] = { 82055, 82056, 82057, 82058, 82059, 82060, 82061, 82062, 82063, 82064, 82065, 82066, 82067, 82068 }, -- 82054, 82069
	["dark_brotherhood"] = { 82055, 82056, 82057, 82058, 82059, 82060, 82061, 82062, 82063, 82064, 82065, 82066, 82067, 82068 }, -- 82054, 82069
	["db"] = { 82055, 82056, 82057, 82058, 82059, 82060, 82061, 82062, 82063, 82064, 82065, 82066, 82067, 82068 }, -- 82054, 82069
	["dro-m'athra"] =  { 74653, 74654, 74655, 74656, 74657, 74658, 74659, 74660, 74661, 74662, 74663, 74664, 74665, 74666 }, -- 74652, 75667  
	["dro m athra"] = { 74653, 74654, 74655, 74656, 74657, 74658, 74659, 74660, 74661, 74662, 74663, 74664, 74665, 74666 }, -- 74652, 75667  
	["dromathra"] = { 74653, 74654, 74655, 74656, 74657, 74658, 74659, 74660, 74661, 74662, 74663, 74664, 74665, 74666 }, -- 74652, 75667  
	["dro_mathra"] = { 74653, 74654, 74655, 74656, 74657, 74658, 74659, 74660, 74661, 74662, 74663, 74664, 74665, 74666 }, -- 74652, 75667  
	["dro"] = { 74653, 74654, 74655, 74656, 74657, 74658, 74659, 74660, 74661, 74662, 74663, 74664, 74665, 74666 }, -- 74652, 75667  
	["minotaur"] =  { 82072, 82073, 82074, 82075, 82076, 82077, 82078, 82079, 82080, 82081, 82082, 82083, 82084, 82085 }, -- 82071, 82086
	["mino"] =  { 82072, 82073, 82074, 82075, 82076, 82077, 82078, 82079, 82080, 82081, 82082, 82083, 82084, 82085 }, -- 82071, 82086
	
			-- Witches Festival
	["grim arlequin"] = { 82039, 82040, 82041, 82042, 82043, 82044, 82045, 82046, 82047, 82048, 82049, 82050, 82051, 82052 }, -- 82038, 82053
	["grim_arlequin"] = { 82039, 82040, 82041, 82042, 82043, 82044, 82045, 82046, 82047, 82048, 82049, 82050, 82051, 82052 }, -- 82038, 82053
	["grim harlequin"] = { 82039, 82040, 82041, 82042, 82043, 82044, 82045, 82046, 82047, 82048, 82049, 82050, 82051, 82052 }, -- 82038, 82053
	["grim_harlequin"] = { 82039, 82040, 82041, 82042, 82043, 82044, 82045, 82046, 82047, 82048, 82049, 82050, 82051, 82052 }, -- 82038, 82053
	["grim"] = { 82039, 82040, 82041, 82042, 82043, 82044, 82045, 82046, 82047, 82048, 82049, 82050, 82051, 82052 }, -- 82038, 82053
	["hollowjack"] = { 82023, 82024, 82025, 82026, 82027, 82028, 82029, 82030, 82031, 82032, 82033, 82034, 82035, 82036 }, -- 82022, 82037
	["hollow"] = { 82023, 82024, 82025, 82026, 82027, 82028, 82029, 82030, 82031, 82032, 82033, 82034, 82035, 82036 }, -- 82022, 82037
		
			-- One Tamriel
	["yokudan"] = { 57606, 57607, 57608, 57609, 57610, 57611, 57612, 57613, 57614, 57615, 57616, 57617, 57618, 57619 }, -- 57605, 64555
	["celestial"] = { 82007, 82008, 82009, 82010, 82011, 82012, 82013, 82014, 82015, 82016, 82017, 82018, 82019, 82020 }, -- 82006, 82021
	["draugr"] = { 76895, 76896, 76897, 76898, 76899, 76900, 76901, 76902, 76903, 76904, 76905, 76906, 76907, 76908 }, -- 76894, 76909
	
		-- New Life Festival
	["skinchanger"] = { 73855, 73856, 73857, 73858, 73859, 73860, 73861, 73862, 73863, 73864, 73865, 73866, 73867, 73868 }, -- 73854, 73869
	["skin"] = { 73855, 73856, 73857, 73858, 73859, 73860, 73861, 73862, 73863, 73864, 73865, 73866, 73867, 73868 }, -- 73854, 73869
	["stalhrim frostcaster"] = 96954,
	["stalhrim"] = 96954,
	["stal"] = 96954,
	["frostcaster"] = 96954, 
	["frost"] = 96954,
	
		-- Homestead
	["silken ring"] = { 114968, 114969, 114970, 114971, 114972, 114973, 114974, 114975, 114976, 114977, 114978, 114979, 114980, 114981 }, -- 114967, 114982,
	["silken_ring"] = { 114968, 114969, 114970, 114971, 114972, 114973, 114974, 114975, 114976, 114977, 114978, 114979, 114980, 114981 }, -- 114967, 114982,
	["silkenring"] = { 114968, 114969, 114970, 114971, 114972, 114973, 114974, 114975, 114976, 114977, 114978, 114979, 114980, 114981 }, -- 114967, 114982,
	["silken"] = { 114968, 114969, 114970, 114971, 114972, 114973, 114974, 114975, 114976, 114977, 114978, 114979, 114980, 114981 }, -- 114967, 114982,
	["mazzatun"] = { 114952, 114953, 114954, 114955, 114956, 114957, 114958, 114959, 114960, 114961, 114962, 114963, 114964, 114965 }, -- 114951, 114966,
	["ra gada"] = { 71673, 71674, 71675, 71676, 71677, 71678, 71679, 71680, 71681, 71682, 71683, 71684, 71685, 71686 }, -- 71672, 71687,
	["ra_gada"] = { 71673, 71674, 71675, 71676, 71677, 71678, 71679, 71680, 71681, 71682, 71683, 71684, 71685, 71686 }, -- 71672, 71687,
	["ragada"] = { 71673, 71674, 71675, 71676, 71677, 71678, 71679, 71680, 71681, 71682, 71683, 71684, 71685, 71686 }, -- 71672, 71687,
	["ebony"] = { 75229, 75230, 75231, 75232, 75233, 75234, 75235, 75236, 75237, 75238, 75239, 75240, 75241, 75242 }, -- 75228, 75243,
	
		-- Morrowind
	["ashlander"] = { 124680, 124681, 124682, 124683, 124684, 124685, 124686, 124687, 124688, 124689, 124690, 124691, 124692, 124693 }, -- 124679, 124694
	["ash"] = { 124680, 124681, 124682, 124683, 124684, 124685, 124686, 124687, 124688, 124689, 124690, 124691, 124692, 124693 }, -- 124679, 124694
	["militant ordinator"] =  { 121349, 121350, 121351, 121352, 121353, 121354, 121355, 121356, 121357, 121358, 121359, 121360, 121361, 121362 }, -- 121348, 121363
	["militant_ordinator"] = { 121349, 121350, 121351, 121352, 121353, 121354, 121355, 121356, 121357, 121358, 121359, 121360, 121361, 121362 }, -- 121348, 121363
	["militantordinator"] = { 121349, 121350, 121351, 121352, 121353, 121354, 121355, 121356, 121357, 121358, 121359, 121360, 121361, 121362 }, -- 121348, 121363
	["ordinator"] = { 121349, 121350, 121351, 121352, 121353, 121354, 121355, 121356, 121357, 121358, 121359, 121360, 121361, 121362 }, -- 121348, 121363
	["militant"] = { 121349, 121350, 121351, 121352, 121353, 121354, 121355, 121356, 121357, 121358, 121359, 121360, 121361, 121362 }, -- 121348, 121363
	["morag tong"] = { 73839, 73840, 73841, 73842, 73843, 73844, 73845, 73846, 73847, 73848, 73849, 73850, 73851, 73852 }, -- 73838, 73853
	["morag_tong"] = { 73839, 73840, 73841, 73842, 73843, 73844, 73845, 73846, 73847, 73848, 73849, 73850, 73851, 73852 }, -- 73838, 73853
	["moragtong"] = { 73839, 73840, 73841, 73842, 73843, 73844, 73845, 73846, 73847, 73848, 73849, 73850, 73851, 73852 }, -- 73838, 73853
	["morag"] = { 73839, 73840, 73841, 73842, 73843, 73844, 73845, 73846, 73847, 73848, 73849, 73850, 73851, 73852 }, -- 73838, 73853
	["buoyant armiger"] = { 121317, 121318, 121319, 121320, 121321, 121322, 121323, 121324, 121325, 121326, 121327, 121328, 121329, 121330 }, -- 121316, 121331
	["buoyant_armiger"] = { 121317, 121318, 121319, 121320, 121321, 121322, 121323, 121324, 121325, 121326, 121327, 121328, 121329, 121330 }, -- 121316, 121331
	["buoyantarmiger"] = { 121317, 121318, 121319, 121320, 121321, 121322, 121323, 121324, 121325, 121326, 121327, 121328, 121329, 121330 }, -- 121316, 121331
	["armiger"] = { 121317, 121318, 121319, 121320, 121321, 121322, 121323, 121324, 121325, 121326, 121327, 121328, 121329, 121330 }, -- 121316, 121331
	["buoyant"] = { 121317, 121318, 121319, 121320, 121321, 121322, 121323, 121324, 121325, 121326, 121327, 121328, 121329, 121330 }, -- 121316, 121331
	
			-- Horns of the Reach
	["redoran"] = { 130011, 130012, 130013, 130014, 130015, 130016, 130017, 130018, 130019, 130020, 130021, 130022, 130023, 130024 }, -- 130025, 130010
	["hlaalu"] = { 129995, 129996, 129997, 129998, 129999, 130000, 130001, 130002, 130003, 130004, 130005, 130006, 130007, 130008 }, -- 130009, 129994
	["telvanni"] = { 121333, 121334, 121335, 121336, 121337, 121338, 121339, 121340, 121341, 121342, 121343, 121344, 121345, 121346 }, -- 121347, 121332
	
		-- Clockwork City
	["bloodforge"] = { 132534, 132535, 132536, 132537, 132538, 132539, 132540, 132541, 132542, 132543, 132544, 132545, 132546, 132547 }, -- 132533, 132548
	["dreadhorn"] = { 132566, 132567, 132568, 132569, 132570, 132571, 132572, 132573, 132574, 132575, 132576, 132577, 132578, 132579 }, -- 132565, 132580
	["apostle"] = { 132550, 132551, 132552, 132553, 132554, 132555, 132556, 132557, 132558, 132559, 132560, 132561, 132562, 132563 }, -- 132549, 132564
	["ebonshadow"] = { 132582, 132583, 132584, 132585, 132586, 132587, 132588, 132589, 132590, 132591, 132592, 132593, 132594, 132595 }, -- 132581, 132596
	
		-- Dragon Bones
	['worm cult'] = { 134740, 134741, 134742, 134743, 134744, 134745, 134746, 134747, 134748, 134749, 134750, 134751, 134752, 134753 }, -- 134739, 134754
	['wormcult'] = { 134740, 134741, 134742, 134743, 134744, 134745, 134746, 134747, 134748, 134749, 134750, 134751, 134752, 134753 }, -- 134739, 134754
	['worm'] = { 134740, 134741, 134742, 134743, 134744, 134745, 134746, 134747, 134748, 134749, 134750, 134751, 134752, 134753 }, -- 134739, 134754
	
		-- Summerset
	['fang lair'] = { 134756, 134757, 134758, 134759, 134760, 134761, 134762, 134763, 134764, 134765, 134766, 134767, 134768, 134769 }, -- 134755, 134770
	['fang_lair'] = { 134756, 134757, 134758, 134759, 134760, 134761, 134762, 134763, 134764, 134765, 134766, 134767, 134768, 134769 }, -- 134755, 134770
	['fanglair'] = { 134756, 134757, 134758, 134759, 134760, 134761, 134762, 134763, 134764, 134765, 134766, 134767, 134768, 134769 }, -- 134755, 134770
	['scalecaller'] = { 134772, 134773, 134774, 134775, 134776, 134777, 134778, 134779, 134780, 134781, 134782, 134783, 134784, 134785 }, -- 134771, 134786
	['psijic order'] = { 137852, 137853, 137854, 137855, 137856, 137857, 137858, 137859, 137860, 137861, 137862, 137863, 137864, 137865 }, -- 137851, 137866
	['psijic_order'] = { 137852, 137853, 137854, 137855, 137856, 137857, 137858, 137859, 137860, 137861, 137862, 137863, 137864, 137865 }, -- 137851, 137866
	['psijicorder'] = { 137852, 137853, 137854, 137855, 137856, 137857, 137858, 137859, 137860, 137861, 137862, 137863, 137864, 137865 }, -- 137851, 137866
	['psijic'] = { 137852, 137853, 137854, 137855, 137856, 137857, 137858, 137859, 137860, 137861, 137862, 137863, 137864, 137865 }, -- 137851, 137866
	['sapiarch'] = { 137921, 137922, 137923, 137924, 137925, 137926, 137927, 137928, 137929, 137930, 137931, 137932, 137933, 137934 }, -- 137920, 137935
	['dremora'] = { 140445, 140446, 140447, 140448, 140449, 140450, 140451, 140452, 140453, 140454, 140455, 140456, 140457, 140458 }, -- 140444, 140459
	['pyandonean'] = { 140268, 140269, 140270, 140271, 140272, 140273, 140274, 140275, 140276, 140277, 140278, 140279, 140280, 140281 }, -- ?, 139055
	['maormer'] = { 140268, 140269, 140270, 140271, 140272, 140273, 140274, 140275, 140276, 140277, 140278, 140279, 140280, 140281 }, -- ?, 139055
	
			-- Wolfhunter
	['welkynar'] = { 140497, 140498, 140499, 140500, 140501, 140502, 140503, 140504, 140505, 140506, 140507, 140508, 140509, 140510 }, -- 140496, 140511
	
			-- Murkmire
	['huntsman']    = { 140463, 140464, 140465, 140466, 140467, 140468, 140469, 140470, 140471, 140472, 140473, 140474, 140475, 140476 }, -- 140462, 140477
	['silver dawn'] = { 140479, 140480, 140481, 140482, 140483, 140484, 140485, 140486, 140487, 140488, 140489, 140490, 140491, 140492 }, -- 140478, 140493
	['silver_dawn'] = { 140479, 140480, 140481, 140482, 140483, 140484, 140485, 140486, 140487, 140488, 140489, 140490, 140491, 140492 }, -- 140478, 140493
	['silverdawn']  = { 140479, 140480, 140481, 140482, 140483, 140484, 140485, 140486, 140487, 140488, 140489, 140490, 140491, 140492 }, -- 140478, 140493
	['dead-water']  = { 142203, 142204, 142205, 142206, 142207, 142208, 142209, 142210, 142211, 142212, 142213, 142214, 142215, 142216 }, -- 142202, 142217
	['deadwater']   = { 142203, 142204, 142205, 142206, 142207, 142208, 142209, 142210, 142211, 142212, 142213, 142214, 142215, 142216 }, -- 142202, 142217
	['elder argonian'] = { 142219, 142220, 142221, 142222, 142223, 142224, 142225, 142226, 142227, 142228, 142229, 142230, 142231, 142231 }, -- 142218, 142223
	['elder_argonian'] = { 142219, 142220, 142221, 142222, 142223, 142224, 142225, 142226, 142227, 142228, 142229, 142230, 142231, 142231 }, -- 142218, 142223
	['elderargonian']  = { 142219, 142220, 142221, 142222, 142223, 142224, 142225, 142226, 142227, 142228, 142229, 142230, 142231, 142231 }, -- 142218, 142223
	
		-- Wrathstone
	['honor guard'] = { 142187, 142188, 142189, 142190, 142191, 142192, 142193, 142194, 142195, 142196, 142197, 142198, 142199, 142200 }, -- 142186, 142201
	['honor_guard'] = { 142187, 142188, 142189, 142190, 142191, 142192, 142193, 142194, 142195, 142196, 142197, 142198, 142199, 142200 }, -- 142186, 142201
	['honorguard'] = { 142187, 142188, 142189, 142190, 142191, 142192, 142193, 142194, 142195, 142196, 142197, 142198, 142199, 142200 }, -- 142186, 142201
	['honor'] = { 142187, 142188, 142189, 142190, 142191, 142192, 142193, 142194, 142195, 142196, 142197, 142198, 142199, 142200 }, -- 142186, 142201
	
		-- Elsweyr
	['coldsnap'] = { 147667, 147668, 147669, 147670, 147671, 147672, 147673, 147674, 147675, 147676, 147677, 147678, 147679, 147680 }, -- 147666, 147681
	['meridian'] = { 147683, 147684, 147685, 147686, 147687, 147688, 147689, 147690, 147691, 147692, 147693, 147694, 147695, 147696 }, -- 147682, 147697
	['anequina'] = { 147699, 147700, 147701, 147702, 147703, 147704, 147705, 147706, 147707, 147708, 147709, 147710, 147711, 147712 }, -- 147698, 147713
	['pellitine'] = { 147715, 147716, 147717, 147718, 147719, 147720, 147721, 147722, 147723, 147724, 147725, 147726, 147727, 147728 }, -- 147714, 147729
		
	-- Dragonhold
	['sunspire'] = { 147731, 147732, 147733, 147734, 147735, 147736, 147737, 147738, 147739, 147740, 147741, 147742, 147743, 147744 }, -- 147730, 147745
	['dragonguard'] = { 156556, 156557, 156558, 156559, 156560, 156561, 156562, 156563, 156564, 156565, 156566, 156567, 156568, 156569 }, -- 156555, 156570
	['moongrave fane'] = { 156591, 156592, 156593, 156594, 156595, 156596, 156597, 156598, 156599, 156600, 156601, 156602, 156603, 156604 }, -- 156590, 156605
	['moongrave_fane'] = { 156591, 156592, 156593, 156594, 156595, 156596, 156597, 156598, 156599, 156600, 156601, 156602, 156603, 156604 }, -- 156590, 156605
	['moongravefane'] = { 156591, 156592, 156593, 156594, 156595, 156596, 156597, 156598, 156599, 156600, 156601, 156602, 156603, 156604 }, -- 156590, 156605
	['moongrave'] = { 156591, 156592, 156593, 156594, 156595, 156596, 156597, 156598, 156599, 156600, 156601, 156602, 156603, 156604 }, -- 156590, 156605
	["stags of z'en"] = { 156574, 156575, 156576, 156577, 156578, 156579, 156580, 156581, 156582, 156583, 156584, 156585, 156586, 156587 }, -- 156573, 156588
	["stags_of_z'en"] = { 156574, 156575, 156576, 156577, 156578, 156579, 156580, 156581, 156582, 156583, 156584, 156585, 156586, 156587 }, -- 156573, 156588
	["stagsofz'en"] = { 156574, 156575, 156576, 156577, 156578, 156579, 156580, 156581, 156582, 156583, 156584, 156585, 156586, 156587 }, -- 156573, 156588
	["stagsofzen"] = { 156574, 156575, 156576, 156577, 156578, 156579, 156580, 156581, 156582, 156583, 156584, 156585, 156586, 156587 }, -- 156573, 156588
	['shield of senchal'] = { 156628, 156629, 156630, 156631, 156632, 156633, 156634, 156635, 156636, 156637, 156638, 156639, 156640, 156641 }, -- 156627, 156642
	['shield_of_senchal'] = { 156628, 156629, 156630, 156631, 156632, 156633, 156634, 156635, 156636, 156637, 156638, 156639, 156640, 156641 }, -- 156627, 156642
	['shieldofsenchal'] = { 156628, 156629, 156630, 156631, 156632, 156633, 156634, 156635, 156636, 156637, 156638, 156639, 156640, 156641 }, -- 156627, 156642
	['senchal'] = { 156628, 156629, 156630, 156631, 156632, 156633, 156634, 156635, 156636, 156637, 156638, 156639, 156640, 156641 }, -- 156627, 156642

	['new moon priest'] = { 156609, 156610, 156611, 156612, 156613, 156614, 156615, 156616, 156617, 156618, 156619, 156620, 156621, 156622 }, -- 156608, 156623
	['new_moon_priest'] = { 156609, 156610, 156611, 156612, 156613, 156614, 156615, 156616, 156617, 156618, 156619, 156620, 156621, 156622 }, -- 156608, 156623
	['newmoonpriest'] = { 156609, 156610, 156611, 156612, 156613, 156614, 156615, 156616, 156617, 156618, 156619, 156620, 156621, 156622 }, -- 156608, 156623
	['newmoon'] = { 156609, 156610, 156611, 156612, 156613, 156614, 156615, 156616, 156617, 156618, 156619, 156620, 156621, 156622 }, -- 156608, 156623
	
		-- Greymoore
	['icereach coven'] = { 157518, 157519, 157520, 157521, 157522, 157523, 157524, 157525, 157526, 157527, 157528, 157529, 157530, 157531 }, -- 157517, 157532
	['icereach_coven'] = { 157518, 157519, 157520, 157521, 157522, 157523, 157524, 157525, 157526, 157527, 157528, 157529, 157530, 157531 }, -- 157517, 157532
	['icereachcoven'] = { 157518, 157519, 157520, 157521, 157522, 157523, 157524, 157525, 157526, 157527, 157528, 157529, 157530, 157531 }, -- 157517, 157532
	['pyre watch'] = { 158292, 158293, 158294, 158295, 158296, 158297, 158298, 158299, 158300, 158301, 158302, 158303, 158304, 158305 }, -- 158291, 158306
	['pyre_watch'] = { 158292, 158293, 158294, 158295, 158296, 158297, 158298, 158299, 158300, 158301, 158302, 158303, 158304, 158305 }, -- 158291, 158306
	['pyrewatch'] = { 158292, 158293, 158294, 158295, 158296, 158297, 158298, 158299, 158300, 158301, 158302, 158303, 158304, 158305 }, -- 158291, 158306
	['blackreach vanguard'] = { 160494, 160495, 160496, 160497, 160498, 160499, 160500, 160501, 160502, 160503, 160504, 160505, 160506, 160507 }, -- 160493, 160508
	['blackreach_vanguard'] = { 160494, 160495, 160496, 160497, 160498, 160499, 160500, 160501, 160502, 160503, 160504, 160505, 160506, 160507 }, -- 160493, 160508
	['blackreachvanguard'] = { 160494, 160495, 160496, 160497, 160498, 160499, 160500, 160501, 160502, 160503, 160504, 160505, 160506, 160507 }, -- 160493, 160508
	['blackreach'] = { 160494, 160495, 160496, 160497, 160498, 160499, 160500, 160501, 160502, 160503, 160504, 160505, 160506, 160507 }, -- 160493, 160508
	['ancestral nord'] = { 160577, 160578, 160579, 160580, 160581, 160582, 160583, 160584, 160585, 160586, 160587, 160588, 160589, 160590 }, -- 160576, 160591
	['ancestral_nord'] = { 160577, 160578, 160579, 160580, 160581, 160582, 160583, 160584, 160585, 160586, 160587, 160588, 160589, 160590 }, -- 160576, 160591
	['ancestralnord'] = { 160577, 160578, 160579, 160580, 160581, 160582, 160583, 160584, 160585, 160586, 160587, 160588, 160589, 160590 }, -- 160576, 160591
	['ancestral high elf'] = { 160594, 160595, 160596, 160597, 160598, 160599, 160600, 160601, 160602, 160603, 160604, 160605, 160606, 160607 }, -- 160593, 160608
	['ancestral_high_elf'] = { 160594, 160595, 160596, 160597, 160598, 160599, 160600, 160601, 160602, 160603, 160604, 160605, 160606, 160607 }, -- 160593, 160608
	['ancestralhighelf'] = { 160594, 160595, 160596, 160597, 160598, 160599, 160600, 160601, 160602, 160603, 160604, 160605, 160606, 160607 }, -- 160593, 160608
	['ancestral orc'] = { 160611, 160612, 160613, 160614, 160615, 160616, 160617, 160618, 160619, 160620, 160621, 160622, 160623, 160624 }, -- 160610, 160625
	['ancestral_orc'] = { 160611, 160612, 160613, 160614, 160615, 160616, 160617, 160618, 160619, 160620, 160621, 160622, 160623, 160624 }, -- 160610, 160625
	['ancestralorc'] = { 160611, 160612, 160613, 160614, 160615, 160616, 160617, 160618, 160619, 160620, 160621, 160622, 160623, 160624 }, -- 160610, 160625
	['greymoore'] = { 160543, 160544, 160545, 160546, 160547, 160548, 160549, 160550, 160551, 160552, 160553, 160554, 160555, 160556 }, -- 160542, 160557
	
		-- Stonethorn
	['sea giant'] = { 160560, 160561, 160562, 160563, 160564, 160565, 160566, 160567, 160568, 160569, 160570, 160571, 160572, 160573 }, -- 160559, 160574
	['sea_giant'] = { 160560, 160561, 160562, 160563, 160564, 160565, 160566, 160567, 160568, 160569, 160570, 160571, 160572, 160573 }, -- 160559, 160574
	['seagiant'] = { 160560, 160561, 160562, 160563, 160564, 160565, 160566, 160567, 160568, 160569, 160570, 160571, 160572, 160573 }, -- 160559, 160574
	
	-- Flames of Ambition
	['ancestral reach'] = { 167271, 167272, 167273, 167274, 167275, 167276, 167277, 167278, 167279, 167280, 167281, 167282, 167283, 167284 }, -- 167270, 167285
	['ancestral_reach'] = { 167271, 167272, 167273, 167274, 167275, 167276, 167277, 167278, 167279, 167280, 167281, 167282, 167283, 167284 }, -- 167270, 167285
	['ancestralreach'] = { 167271, 167272, 167273, 167274, 167275, 167276, 167277, 167278, 167279, 167280, 167281, 167282, 167283, 167284 }, -- 167270, 167285
	['night hollow'] = { 167944, 167945, 167946, 167947, 167948, 167949, 167950, 167951, 167952, 167953, 167954, 167955, 167956, 167957 }, -- 167943, 167958
	['night_hollow'] = { 167944, 167945, 167946, 167947, 167948, 167949, 167950, 167951, 167952, 167953, 167954, 167955, 167956, 167957 }, -- 167943, 167958
	['nighthollow'] = { 167944, 167945, 167946, 167947, 167948, 167949, 167950, 167951, 167952, 167953, 167954, 167955, 167956, 167957 }, -- 167943, 167958
	['arkthzand armory'] = { 167961, 167962, 167963, 167964, 167965, 167966, 167967, 167968, 167969, 167970, 167971, 167972, 167973, 167974 }, -- 167960, 167975
	['arkthzand_armory'] = { 167961, 167962, 167963, 167964, 167965, 167966, 167967, 167968, 167969, 167970, 167971, 167972, 167973, 167974 }, -- 167960, 167975
	['arkthzandarmory'] = { 167961, 167962, 167963, 167964, 167965, 167966, 167967, 167968, 167969, 167970, 167971, 167972, 167973, 167974 }, -- 167960, 167975
	['arkthzand'] = { 167961, 167962, 167963, 167964, 167965, 167966, 167967, 167968, 167969, 167970, 167971, 167972, 167973, 167974 }, -- 167960, 167975
	['wayward guardian'] = { 167978, 167979, 167980, 167981, 167982, 167983, 167984, 167985, 167986, 167987, 167988, 167989, 167990, 167991 }, -- 167977, 167992
	['wayward_guardian'] = { 167978, 167979, 167980, 167981, 167982, 167983, 167984, 167985, 167986, 167987, 167988, 167989, 167990, 167991 }, -- 167977, 167992
	['waywardguardian'] = { 167978, 167979, 167980, 167981, 167982, 167983, 167984, 167985, 167986, 167987, 167988, 167989, 167990, 167991 }, -- 167977, 167992
	['wayward'] = { 167978, 167979, 167980, 167981, 167982, 167983, 167984, 167985, 167986, 167987, 167988, 167989, 167990, 167991 }, -- 167977, 167992
	
}


uespLog.CRAFTMOTIF_CHAPTERNAME = {
	[1] = "Axes",
	[2] = "Belts",
	[3] = "Boots",
	[4] = "Bows",
	[5] = "Chests",
	[6] = "Daggers",
	[7] = "Gloves",
	[8] = "Helmets",
	[9] = "Legs",
	[10] = "Maces",
	[11] = "Shields",
	[12] = "Shoulders",
	[13] = "Staves",
	[14] = "Swords",
}


function uespLog.MatchUnknownStylePrefix(styleName)
	local maxStyle = GetHighestItemStyleId()
	
	styleName = styleName:lower()
		
	for i = 1, maxStyle do
		local name = GetItemStyleName(i) or ""
		name = name:lower()
		
		if (name == styleName) then
			return styleName, i
		elseif (uespLog.BeginsWith(name, styleName)) then
			return GetItemStyleName(i), i
		end
	
	end
	
	return nil, -1
end


function uespLog.GetStyleKnown(styleName)
	local known = false
	local knowAll = true
	local unknownAll = true
	local numStyles = GetNumSmithingStyleItems()
	local styleIndex
	local cmpStyleName = string.lower(styleName)
	local itemStyle = uespLog.CRAFTSTYLENAME_TO_ITEMSTYLE[cmpStyleName] or 0
	local motifId = uespLog.CRAFTSTYLENAME_TO_MOTIFID[cmpStyleName] or false
	local knownCount = 0
		
	if (cmpStyleName == "") then
		return nil, 0, -1, styleName
	end	
	
	if (itemStyle <= 0 or not motifId) then
		cmpStyleName, itemStyle = uespLog.MatchUnknownStylePrefix(styleName)
		
		if (cmpStyleName) then
			cmpStyleName = string.lower(cmpStyleName)
			motifId = uespLog.CRAFTSTYLENAME_TO_MOTIFID[cmpStyleName] or false
		end
	end
	
	if (itemStyle <= 0 or not motifId) then
		return nil, 0, -1, styleName
	end
	
	if (type(motifId) == "table") then
		known = { }
	
		for i = 1,14 do
			local itemLink = uespLog.MakeItemLink(motifId[i], 1, 1)
			known[i] = IsItemLinkBookKnown(itemLink)
			
			if (known[i]) then
				knownCount = knownCount + 1
			end
			
			knowAll = knowAll and known[i]
			unknownAll = unknownAll and not known[i]
		end
		
		if (knowAll) then
			known = true
			knownCount = 14
		elseif (unknownAll) then
			known = false
			knownCount = 0
		end
	else
		local itemLink = uespLog.MakeItemLink(motifId)
		known = IsItemLinkBookKnown(itemLink)
		knowAll = known	
		knownCount = 14
	end
	
	return known, knownCount, itemStyle, GetItemStyleName(itemStyle)
end


function uespLog.firstToUpper(str)
    return tostring(str):gsub("^%l", string.upper)
end


function uespLog.titleCaseHelper( first, rest )
   return first:upper() .. rest:lower()
end

function uespLog.titleCaseString(str)
	--local lStr = tostring(str):lower()
    --return lStr:gsub("(%l)(%w*)", function(a,b) return string.upper(a)..b end)
	
	return tostring(str):gsub("(%a)([%w_']*)", uespLog.titleCaseHelper)
end


function uespLog.ShowStyles(styleName, showLong)
	local known, knownCount, styleId, fullStyleName = uespLog.GetStyleKnown(styleName)
	local niceName = uespLog.titleCaseString(fullStyleName)
	
	showLong = showLong or false
	
	if (known == nil) then
		uespLog.MsgColor(uespLog.craftColor, "Error: Unknown item style '"..tostring(styleName).."'!")
		uespLog.MsgColor(uespLog.craftColor, ".                Use '/uespstyle list' to show valid styles.")
		return false
	elseif (type(known) == "table") then
		local knownPieces = {}
		local unknownPieces = {}
		local totalPieces = 14
	
		for i = 1, totalPieces do
			local chapterName = tostring(uespLog.CRAFTMOTIF_CHAPTERNAME[i])
			local knownString = "UNKNOWN"
			
			if (known[i]) then
				knownString = "known"
				table.insert(knownPieces, chapterName)
			else
				table.insert(unknownPieces, chapterName)
			end
			
			if (showLong) then
				uespLog.MsgColor(uespLog.craftColor, niceName.." style Chapter "..tostring(i)..", "..chapterName.." is "..knownString)
			end
		end
		
		if (not showLong) then
			local knownString   = uespLog.implodeOrder(knownPieces, ", ")
			local unknownString = uespLog.implodeOrder(unknownPieces, ", ")
			uespLog.MsgColor(uespLog.craftColor, niceName.." style known pieces ("..tostring(#knownPieces).."): "..knownString)
			uespLog.MsgColor(uespLog.craftColor, niceName.." style UNKNOWN pieces ("..tostring(#unknownPieces).."): "..unknownString)

			uespLog.MsgColor(uespLog.craftColor, "You know "..tostring(#knownPieces).."/"..tostring(totalPieces).." of the "..niceName.." style chapters.")
		end
		
	elseif (known) then
		uespLog.MsgColor(uespLog.craftColor, niceName.." style is known for all pieces (14/14)")
	else
		uespLog.MsgColor(uespLog.craftColor, niceName.." style is UNKNOWN for all pieces (0/14)")
	end
	
	return true
end


function uespLog.ListValidStyles()
	local maxStyle = GetHighestItemStyleId()
	local universalStyle = GetUniversalStyleId()
	local orderedNames = {}
	local output = ""
	local j = 1
	
	uespLog.MsgColor(uespLog.craftColor, "Valid style names are:")
	
	for i = 1, maxStyle do
		local name = GetItemStyleName(i)
		
		if (name ~= "" and name ~= nil and i ~= universalStyle) then
			orderedNames[i] = name
		end
	end
	
	table.sort(orderedNames)
	
	for i = 1, #orderedNames do
		local niceName = uespLog.titleCaseString(orderedNames[i])
		
		output = output .. niceName .. string.rep(" ", 20 - #niceName/1.5)
		j = j + 1
					
		if (j >= 4) then
			j = 1
			uespLog.MsgColor(uespLog.craftColor, output)
			output = ""
		end
	end
	
	if (output ~= "") then
		uespLog.MsgColor(uespLog.craftColor, output)
	end
		
end


uespLog.EXCLUDE_STYLES_MASTERWRIT = {
	[ITEMSTYLE_RACIAL_NORD] 		 = true,
	[ITEMSTYLE_RACIAL_REDGUARD]  	 = true,
	[ITEMSTYLE_RACIAL_ORC]  		 = true,
	[ITEMSTYLE_RACIAL_KHAJIIT]  	 = true,
	[ITEMSTYLE_RACIAL_HIGH_ELF]  	 = true,
	[ITEMSTYLE_RACIAL_WOOD_ELF]  	 = true,
	[ITEMSTYLE_RACIAL_ARGONIAN]  	 = true,
	[ITEMSTYLE_RACIAL_BRETON]  		 = true,
	[ITEMSTYLE_RACIAL_DARK_ELF] 	 = true,
	[ITEMSTYLE_UNIVERSAL]			 = true,
	[30]							 = true, -- Soul Shriven
	[53]							 = true, -- Frostcaster
	[58]							 = true, -- Harlequin
	[38]							 = true, -- Tsaesci
}


function uespLog.GetStyleData(sortById)
	local numStyles = GetNumSmithingStyleItems()
	local styleData = {}
	
	for i = 1, numStyles do
		local styleItemName, _, _, _, itemStyle = GetSmithingStyleItemInfo(i)
		local styleName = GetItemStyleName(itemStyle)
		
		if (styleItemName ~= "" and styleName ~= "") then 
			styleData[#styleData + 1] = { ["name"] = styleName, ["style"] = itemStyle }
		end
	end
	
	if (sortById) then
		table.sort(styleData, function (a, b) return a.style < b.style end)
	else
		table.sort(styleData, function (a, b) return a.name < b.name end)
	end
	
	return styleData
end


function uespLog.ShowStyleSummary(showKnown, showUnknown, showMasterWrit, sortById, showMaterials)
	local numStyles = GetNumSmithingStyleItems()
	local totalKnown = 0
	local totalUnknown = 0
	local validStyles = 0
	local styleData = uespLog.GetStyleData(sortById)
	local displayCount = 0
	local writCount = 0
				
	if (showKnown) then
		uespLog.MsgColor(uespLog.craftColor, "Showing summary for all completely known styles:")
	elseif (showUnknown) then
		uespLog.MsgColor(uespLog.craftColor, "Showing summary for all unknown styles:")
	elseif (showMasterWrit) then
		uespLog.MsgColor(uespLog.craftColor, "Showing summary for all styles contributing to master writ chance:")
	else
		uespLog.MsgColor(uespLog.craftColor, "Showing summary for all styles:")
	end
	
	for i, data in ipairs(styleData) do
		local styleName = data.name
		local itemStyle = data.style
		local known, knownCount = uespLog.GetStyleKnown(styleName)	
		local displayStyle = true
		local materialLink = GetItemStyleMaterialLink(itemStyle)
		local msg = ""
		
		if (styleItemName ~= "" and styleName ~= "" and styleName ~= "Universal") then 
			validStyles = validStyles + 1
			
			if (showKnown and knownCount < 14) then
				displayStyle = false
			elseif (showUnknown and knownCount >= 14) then
				displayStyle = false
			elseif (showMasterWrit and uespLog.EXCLUDE_STYLES_MASTERWRIT[itemStyle] ~= nil) then
				displayStyle = false
			end
		
			if (displayStyle) then
				totalKnown = totalKnown + knownCount
				totalUnknown = totalUnknown + 14 - knownCount
				displayCount = displayCount + 1
				
				if (knownCount >= 14) then
					writCount = writCount + 1
				end
				
				if (sortById) then
					msg = ".    "..tostring(itemStyle)..") " .. tostring(styleName).. " = "..knownCount.."/14"
				else
					msg = ".    "..tostring(styleName).." (" .. tostring(itemStyle) .. ") = "..knownCount.."/14"
				end
				
				if (showMaterials) then
					local stack1, stack2, stack3 = GetItemLinkStacks(materialLink)
					local stack = stack1 + stack2 + stack3
					msg = msg .. "  ("..tostring(materialLink).." x" .. tostring(stack)..")"
				end
				
				uespLog.MsgColor(uespLog.craftColor, msg)
			end
		end
	end
	
	if (showKnown) then
		uespLog.MsgColor(uespLog.craftColor, "You completely know "..displayCount.."/"..validStyles.." styles.")
	elseif (showUnknown) then
		uespLog.MsgColor(uespLog.craftColor, "You do not know "..displayCount.."/"..validStyles.." styles.")
	elseif (showMasterWrit) then
		uespLog.MsgColor(uespLog.craftColor, "You completely know "..writCount.."/"..displayCount.." styles.")
	else
		uespLog.MsgColor(uespLog.craftColor, "You know "..totalKnown.."/"..tostring(14*validStyles).." style chapters.")
		uespLog.MsgColor(uespLog.craftColor, "You know "..writCount.."/"..tostring(validStyles).." complete motifs.")
	end
end


function uespLog.StyleCommand(cmd)
	local cmds, firstCmd = uespLog.SplitCommands(cmd)
	
	if (cmd == "") then
		uespLog.MsgColor(uespLog.craftColor, "Shows which chapters of the item style you know.")
		uespLog.MsgColor(uespLog.craftColor, ".       /uespstyle [style]              Shows which chapters you know")
		uespLog.MsgColor(uespLog.craftColor, ".       /uespstyle long [style]      Shows chapters in old long format")
		uespLog.MsgColor(uespLog.craftColor, ".       /uespstyle list                     Lists all valid styles")
		uespLog.MsgColor(uespLog.craftColor, ".       /uespstyle summary           Displays a summary of all styles")
		uespLog.MsgColor(uespLog.craftColor, ".       /uespstyle summaryid       Displays a summary of all styles by ID")
		uespLog.MsgColor(uespLog.craftColor, ".       /uespstyle known               Show all completely known styles")
		uespLog.MsgColor(uespLog.craftColor, ".       /uespstyle unknown           Show any styles not completely known")
		uespLog.MsgColor(uespLog.craftColor, ".       /uespstyle master              Show styles related to master writ chance")
		uespLog.MsgColor(uespLog.craftColor, ".       /uespstyle material          Show style material info")
	elseif (firstCmd == "master" or firstCmd == "writ") then
		uespLog.ShowStyleSummary(false, false, true)
	elseif (firstCmd == "unknown") then
		uespLog.ShowStyleSummary(false, true, false)
	elseif (firstCmd == "known") then
		uespLog.ShowStyleSummary(true, false, false)
	elseif (firstCmd == "liststyles" or firstCmd == "list") then
		uespLog.ListValidStyles()
	elseif (firstCmd == "summary" or firstCmd == "all") then
		uespLog.ShowStyleSummary(false, false, false, false, false)
	elseif (firstCmd == "summaryid" or firstCmd == "allid") then
		uespLog.ShowStyleSummary(false, false, false, true, false)
	elseif (firstCmd == "material" or firstCmd == "materials") then
		uespLog.ShowStyleSummary(false, false, false, false, true)
	elseif (firstCmd == "long") then
		uespLog.ShowStyles(uespLog.implodeOrder(cmds, " ", 2), true)
	else
		uespLog.ShowStyles(cmd)
	end	
	
end


SLASH_COMMANDS["/uespstyle"]  = uespLog.StyleCommand
SLASH_COMMANDS["/uespstyles"] = uespLog.StyleCommand


function uespLog.ShowTargetInfo ()
	--local unitTag = "reticleover"
    --local type = GetUnitType(unitTag)
    --local name = GetUnitName(unitTag)
	--local x, y, z, zone = uespLog.GetUnitPosition(unitTag)
	--local level = GetUnitLevel(unitTag)
	--local gender = GetUnitGender(unitTag)
	--local class = GetUnitClass(unitTag)
	--local race = GetUnitRace(unitTag)
	--local difficulty = GetUnitDifficulty(unitTag)
	--local currentHp, maxHp, effectiveHp = GetUnitPower(unitTag, POWERTYPE_HEALTH)
	--local currentMg, maxMg, effectiveMg = GetUnitPower(unitTag, POWERTYPE_MAGICKA)
	--local currentSt, maxSt, effectiveSt = GetUnitPower(unitTag, POWERTYPE_STAMINA)
	--uespLog.Msg("Name:"..tostring(name)..", type:"..tostring(type)..", level:"..tostring(level)..", gender:"..tostring(gender)..", class:"..tostring(class)..", race:"..tostring(race))
	
	if (uespLog.lastTargetData == nil) then
		return
	end
	
	uespLog.Msg("Last Target Info -- Name:"..tostring(uespLog.lastTargetData.name)..", type:"..tostring(uespLog.lastTargetData.type)..", level:"..tostring(uespLog.lastTargetData.level)..", gender:"..tostring(uespLog.lastTargetData.gender)..", class:"..tostring(uespLog.lastTargetData.class)..", race:"..tostring(uespLog.lastTargetData.race)..",  maxHP:"..tostring(uespLog.lastTargetData.maxHp)..",  maxMG:"..tostring(uespLog.lastTargetData.maxMg)..",  maxST:"..tostring(uespLog.lastTargetData.maxSt))
end


function uespLog.UpdateCoordinates()
    local mouseOverControl = WINDOW_MANAGER:GetMouseOverControl()

    if (uespLog.GetShowCursorMapCoordsFlag() and not ZO_WorldMapContainer:IsHidden() and (mouseOverControl == ZO_WorldMapContainer or mouseOverControl:GetParent() == ZO_WorldMapContainer)) then
        local currentOffsetX = ZO_WorldMapContainer:GetLeft()
        local currentOffsetY = ZO_WorldMapContainer:GetTop()
        local parentOffsetX = ZO_WorldMap:GetLeft()
        local parentOffsetY = ZO_WorldMap:GetTop()
        local mouseX, mouseY = GetUIMousePosition()
        local mapWidth, mapHeight = ZO_WorldMapContainer:GetDimensions()
        local parentWidth, parentHeight = ZO_WorldMap:GetDimensions()

        local normalizedX = math.floor((((mouseX - currentOffsetX) / mapWidth) * 1000) + 0.5)/1000
        local normalizedY = math.floor((((mouseY - currentOffsetY) / mapHeight) * 1000) + 0.5)/1000
		local xStr = string.format("%.03f", normalizedX)
		local yStr = string.format("%.03f", normalizedY)

        uespLogCoordinates:SetAlpha(0.8)
        uespLogCoordinates:SetDrawLayer(ZO_WorldMap:GetDrawLayer() + 1)
        uespLogCoordinates:SetAnchor(TOPLEFT, nil, TOPLEFT, parentOffsetX + 0, parentOffsetY + parentHeight)
        uespLogCoordinatesValue:SetText("Coordinates: " .. tostring(xStr) .. ", " .. tostring(yStr))
    else
        uespLogCoordinates:SetAlpha(0)
    end
end


function uespLog.DumpSmithItems(onlySetItems)
	local numPatterns = GetNumSmithingPatterns()
	local numStyles = GetNumSmithingStyleItems()
	local numImprovementItems = GetNumSmithingImprovementItems()
	local numTraitItems = GetNumSmithingTraitItems()
	local craftingType = GetCraftingInteractionType()
	local tradeskillName = uespLog.GetCraftingName(craftingType)
	
	if (numPatterns == 0 or craftingType == 0) then
		uespLog.Msg("You must be using a smithing station for this to work!")
		return
	end
	
	local startPattern = 1
	
	if (onlySetItems) then
		if (craftingType == CRAFTING_TYPE_BLACKSMITHING) then
			startPattern = 15
		elseif (craftingType == CRAFTING_TYPE_CLOTHIER) then
			startPattern = 15
		elseif (craftingType == CRAFTING_TYPE_WOODWORKING) then
			startPattern = 7
		elseif (craftingType == CRAFTING_TYPE_JEWELRYCRAFTING) then
			startPattern = 7 --TODO18
		end
		
		if (startPattern > numPatterns) then
			uespLog.Msg("You must be at a set smithing station for this to work!")	
			return
		end
		
		uespLog.Msg("Dumping set items for "..tradeskillName.."...")
	else
		uespLog.Msg("Dumping items for "..tradeskillName.."...")
	end
		
	--GetSmithingImprovementItemInfo(CRAFTING_TYPE_BLACKSMITHING, luaindex improvementItemIndex)
		--Returns: string itemName, textureName icon, integer currentStack, integer sellPrice, bool meetsUsageRequirement, integer equipType, integer itemStyle, integer quality
	--local itemLink = GetSmithingImprovementItemLink(TradeskillType craftingSkillType, luaindex improvementItemIndex, LinkStyle linkStyle)
	--GetSmithingImprovedItemInfo(integer itemToImproveBagId, integer itemToImproveSlotIndex, TradeskillType craftingSkillType)
		--Returns: string itemName, textureName icon, integer sellPrice, bool meetsUsageRequirement, integer equipType, integer itemStyle, integer quality
	--local itemLink = GetSmithingImprovedItemLink(integer itemToImproveBagId, integer itemToImproveSlotIndex, TradeskillType craftingSkillType, LinkStyle linkStyle)

	--local itemLink = GetSmithingPatternMaterialItemLink(luaindex patternIndex, luaindex materialIndex, LINK_STYLE_DEFAULT)
	--local itemLink = GetSmithingPatternResultLink(luaindex patternIndex, luaindex materialIndex, integer materialQuantity, luaindex styleIndex, luaindex traitIndex, LINK_STYLE_DEFAULT)
	
	--local patternName, baseName, icon, numMaterials, numTraitsRequired, numTraitsKnown, resultItemFilterType = GetSmithingPatternInfo(2)
	--local itemLink = GetSmithingPatternResultLink(2, 1, 7, 1, 1, LINK_STYLE_DEFAULT)
	--local itemName, itemColor, itemId, itemLevel, itemData, itemNiceName, itemNiceLink = uespLog.ParseLinkID(itemLink)
	--uespLog.DebugMsg("UESP: Num Materials = " .. tostring(numMaterials))
	--uespLog.DebugMsg("UESP: Item " .. tostring(itemNiceLink))
	--uespLog.DebugMsg("UESP: Item ID " .. tostring(itemId))	
	--uespLog.DebugMsg("UESP: Item Level " .. tostring(itemLevel))
	
	local itemCount = 0
	local logData = { }
	local maxItemCount = 10000
	local timeData = uespLog.GetTimeData()
	
	if true then
		--return
	end
	
	for patternIndex = startPattern, numPatterns do
		local patternName, baseName, icon, numMaterials, numTraitsRequired, numTraitsKnown, resultItemFilterType = GetSmithingPatternInfo(2)
		
		logData = { }
		local styleIndex = 1
		
		--for materialIndex = 1, numMaterials do
		materialIndex = 1
		
			for traitIndex = 1, numTraitItems do
			
				for materialQuantity = 3, 14 do
					local itemLink = GetSmithingPatternResultLink(patternIndex, materialIndex, materialQuantity, styleIndex, traitIndex, LINK_STYLE_DEFAULT)
				
					if (itemLink ~= "") then
						local itemName, itemColor, itemId, itemLevel, itemData, itemNiceName, itemNiceLink = uespLog.ParseLinkID(itemLink)
						
						logData = { }
						
						logData.event = "ItemDump::Smith"
						logData.craftType = craftingType
						logData.itemLink = itemLink
						logData.itemId = itemId
						logData.level = itemLevel
						logData.itemName = itemNiceName
						logData.pattern = patternIndex
						logData.style = styleIndex
						logData.material = materialIndex
						logData.materialQnt = materialQuantity
						logData.trait = traitIndex
						
						uespLog.AppendDataToLog("all", logData, timeData)
						
						itemCount = itemCount + 1
						break
					end
				end
				
				if (itemCount > maxItemCount) then
					return
				end
				
			end
		--end
	end
	
	uespLog.Msg("Output Items " .. tostring(itemCount))
end


SLASH_COMMANDS["/uespsmithtest"] = function (cmd)
	uespLog.DumpSmithItems(false)
end


SLASH_COMMANDS["/uespsmithsetdump"] = function (cmd)
	uespLog.DumpSmithItems(true)
end


SLASH_COMMANDS["/uespsmithinfo"] = function (cmd)
	local numPatterns = GetNumSmithingPatterns()
	local numStyles = GetNumSmithingStyleItems()
	local numImprovementItems = GetNumSmithingImprovementItems()
	local numTraitItems = GetNumSmithingTraitItems()
	local craftingType = GetCraftingInteractionType()
	local tradeskillName = uespLog.GetCraftingName(craftingType)
	
	uespLog.Msg("Craft Type(" .. tostring(craftingType) .. ") = " .. tradeskillName)
	uespLog.Msg("Num Patterns = " .. tostring(numPatterns))
	uespLog.Msg("Num Styles = " .. tostring(numStyles))
	uespLog.Msg("Num Improvements = " .. tostring(numImprovementItems))
	uespLog.Msg("Num Traits = " .. tostring(numTraitItems))	
end


function uespLog.MakeEnchantLink(enchantId, inputLevel, inputType, inputItemId, inputItemLevel, inputItemType)
	local enchantLevel = inputLevel or 1
	local enchantType = inputType or 1
	local itemId = inputItemId or 70
	local itemLevel = inputItemLevel or 1
	local itemType = inputItemType or 1
		
	local itemLink = "|H0:item:"..tostring(itemId)..":"..tostring(itemType)..":"..tostring(itemLevel)..":"..tostring(enchantId)..":"..tostring(enchantType)..":"..tostring(enchantLevel)..":0:0:0:0:0:0:0:0:0:0:0:0:0:0|h[Item "..tostring(itemId).."]|h"

	local itemName = GetItemLinkName(itemLink)
	
	if (itemName ~= "" and itemName ~= nil) then
		itemLink = "|H0:item:"..tostring(itemId)..":"..tostring(itemType)..":"..tostring(itemLevel)..":"..tostring(enchantId)..":"..tostring(enchantType)..":"..tostring(enchantLevel)..":0:0:0:0:0:0:0:0:0:0:0:0:0:0|h["..tostring(itemName).."]|h"
		itemLink = "|H0:item:"..tostring(itemId)..":"..tostring(itemType)..":"..tostring(itemLevel)..":"..tostring(enchantId)..":"..tostring(enchantType)..":"..tostring(enchantLevel)..":"..tostring(enchantId)..":"..tostring(enchantType)..":"..tostring(enchantLevel)..":0:0:0:0:0:0:0:0:0:0:0|h["..tostring(itemName).."]|h"
	end
	
	return itemLink
end



function uespLog.MakeItemLink(itemId, inputLevel, inputQuality)
	local itemLevel = inputLevel or 50
	local itemQuality = inputQuality or 370
	
	local itemLink = "|H0:item:"..tostring(itemId)..":"..tostring(itemQuality)..":"..tostring(itemLevel)..":0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"
	
	return itemLink
end


function uespLog.MakeItemLinkEx(itemData)
	--     |H0:item:ID:SUBTYPE:LEVEL:ENCHANTID:ENCHANTSUBTYPE:ENCHANTLEVEL:WRIT1:WRIT2:WRIT3:WRIT4:WRIT5:WRIT6:0:0:0:0:STYLE:CRAFTED:BOUND:CHARGES:POTIONEFFECT|hNAME|h
	local itemId = itemData.itemId or 1
	local itemLevel = itemData.level or 1
	local itemQuality = itemData.quality or itemData.inttype or itemData.intSubtype or itemData.intSubType or 1
	local enchantId = itemData.enchantId or 0
	local enchantQuality = itemData.enchantQuality or 0
	local enchantLevel = itemData.enchantLevel or 0
	local style = itemData.style or 0
	local potionEffect = itemData.potionEffect or itemData.vouchers or 0
	local charges = itemData.charges or 0
	local bound = itemData.bound or 0
	local crafted = itemData.crafted or 0
	local writ1 = itemData.writ1 or 0
	local writ2 = itemData.writ2 or 0
	local writ3 = itemData.writ3 or 0
	local writ4 = itemData.writ4 or 0
	local writ5 = itemData.writ5 or 0
	local writ6 = itemData.writ6 or 0
	
	local itemLinkBase = "|H0:item:"..tostring(itemId)..":"..tostring(itemQuality)..":"..tostring(itemLevel)..":"..
			tostring(enchantId)..":"..tostring(enchantQuality)..":"..tostring(enchantLevel)..":"..tostring(writ1)..":"..
			tostring(writ2)..":"..tostring(writ3)..":"..tostring(writ4)..":"..tostring(writ5)..":"..tostring(writ6)..":0:0:0:0:"..
			tostring(style)..":"..tostring(crafted)..":"..tostring(bound)..":"..tostring(charges)..":"..tostring(potionEffect).."|h"
		
	local itemLink = itemLinkBase .. "|h"
	return itemLink
end


SLASH_COMMANDS["/uespcomparelink"] = function (cmd)
	local cmds = { }
	
	for word in cmd:gmatch("%S+") do table.insert(cmds, word) end
	
	local itemId = cmds[1]
	
	if (itemId == nil) then
		uespLog.Msg("Use the format: /uespcomparelink [id]")
		return
	end
	
	local itemLink1 = uespLog.MakeItemLink(itemId, 1, 1)
	local itemLink2 = uespLog.MakeItemLink(itemId, 50, 312)
	
	resultDiff = uespLog.CompareItemLinks(itemLink1, itemLink2)
	
	uespLog.Msg("Comparing items "..tostring(itemLink1).." and "..tostring(itemLink2).."")
	d(resultDiff)
end


SLASH_COMMANDS["/uespmakelink"] = function (cmd)
	local cmds = { }
	
	for word in cmd:gmatch("%S+") do table.insert(cmds, word) end
	
	local itemId = cmds[1]
	
	if (itemId == nil) then
		uespLog.Msg("Use the format: /uespmakelink [id] [level] [subtype]")
		return
	end
	
	local itemLink = uespLog.MakeItemLink(itemId, cmds[2], cmds[3])
	
	local icon = GetItemLinkIcon(itemLink)

	if (icon == nil or icon == "") then
		uespLog.Msg("Item "..tostring(itemId).." is not valid!")
		return
	end
	
	uespLog.Msg("Created Item Link "..itemLink)
	
	uespLog.DebugExtraMsg("Icon "..tostring(icon))
	
	ZO_PopupTooltip_SetLink(itemLink)
end


SLASH_COMMANDS["/uespmakeenchant"] = function (cmd)
	local cmds = { }
	for word in cmd:gmatch("%S+") do table.insert(cmds, word) end
	local enchantId = cmds[1]
	
	if (enchantId == nil) then
		uespLog.Msg("Use the format: /uespmakeenchant [id] [level] [subtype] [itemid] [itemlevel] [itemsubtype]")
		return
	end
	
	local itemLink = uespLog.MakeEnchantLink(enchantId, cmds[2], cmds[3], cmds[4], cmds[5], cmds[6])
	uespLog.Msg("Created Enchant Link "..itemLink)
	
	ZO_PopupTooltip_SetLink(itemLink)
end


SLASH_COMMANDS["/uesptestdump"] = function(cmd)

	uespLog.printDumpObject = true
	uespLog.logDumpObject = false
	
	uespLog.DumpObject("", "BANK_FRAGMENT", BANK_FRAGMENT, 0, 3)
	uespLog.DebugMsg("CC"..tostring(#BANK_FRAGMENT))
	uespLog.DumpObject("", "BANK_FRAGMENT", BANK_FRAGMENT.control, 0, 3)
	
	local tmpTable = getmetatable(BANK_FRAGMENT.control)
	
	if (tmpTable ~= nil) then
		uespLog.DebugMsg("DD"..tostring(#tmpTable))
		--uespLog.DumpObject("", "BANK_FRAGMENT", tmpTable, 0, 3)
	end --]]
	
	--[[
	uespLog.DumpObject("", "TreasureMap", TreasureMap, 0, 3)
	uespLog.DebugMsg("AA"..tostring(#TreasureMap.__index))
	uespLog.DumpObject("", "TreasureMap", TreasureMap.__index, 0, 3)
	
	local tmpTable = getmetatable(TreasureMap)
	
	if (tmpTable ~= nil) then
		uespLog.DebugMsg("BB"..tostring(#tmpTable))
		uespLog.DumpObject("", "TreasureMap.__meta", tmpTable, 0, 3)
	end	--]]
	
	uespLog.printDumpObject = false
	uespLog.logDumpObject = true	
end


function uespLog.DumpToolTip ()
	uespLog.DebugMsg("Dumping tooltip "..tostring(PopupTooltip))
	
	uespLog.printDumpObject = true
	--uespLog.DumpObject("", "PopupTooltip", getmetatable(PopupTooltip), 0, 2)
		
	--for k, v in pairs(PopupTooltip) do
		--uespLog.DebugMsg(".    " .. tostring(k) .. "=" .. tostring(v))
	--end
	
	local numChildren = PopupTooltip:GetNumChildren()
	uespLog.DebugMsg("Has "..tostring(numChildren).." children")
	
    for i = 1, numChildren do
        local child = PopupTooltip:GetChild(i)
		--uespLog.DumpObject("", "child", getmetatable(child), 0, 2)
		local name = child:GetName()
		uespLog.DebugMsg(".   "..tostring(i)..") "..tostring(name))
    end
	
	uespLog.printDumpObject = false
end


function uespLog.DumpItems()
	--	d("|HFFFFFF:item:45817:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|hJode|h test item")
	local itemLink = ""
	local startId = 1
	local endId = 100
	local logData = { }
	
	for itemId = startId, endId do
		itemLink = "|HFFFFF:item:"..itemId..":1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|hUnknown|h"
		local icon, sellPrice, meetsUsageRequirement, equipType, itemStyle = GetItemLinkInfo(itemLink)

	end	
	
end


function uespLog.OnGoldPickpocketed(eventCode, goldAmount)
	uespLog.DebugExtraMsg("Pickpocketed "..tostring(goldAmount).." gold")
end


function uespLog.OnGoldRemoved(eventCode, goldAmount)
	uespLog.DebugExtraMsg("Justice: Removed "..tostring(goldAmount).." gold")
end


-- Note: This event does not seem to be called
function uespLog.OnItemPickpocketed (eventCode, itemName, itemCount)

	if (itemCount == 1) then
		uespLog.DebugExtraMsg("Pickpocketed "..tostring(itemName))
	else
		uespLog.DebugExtraMsg("Pickpocketed "..tostring(itemName).." (x"..tostring(itemCount)..")")
	end
	
	local logData = {}
	
	logData.event = "PickpocketItem"
	logData.ppBonus, logData.ppIsHostile, logData.ppChance, logData.ppDifficulty, logData.ppEmpty, logData.ppResult, logData.ppClassString, logData.ppClass = GetGameCameraPickpocketingBonusInfo()
	logData.item = itemName
	logData.count = itemCount

	uespLog.AppendDataToLog("all", logData, uespLog.GetLastTargetData(), uespLog.GetTimeData())
end


function uespLog.OnPickpocketFailed(eventCode)
	local logData = {}
	local unitTag = "reticleover"
	
	logData.event = "PickpocketFailed"
	logData.ppBonus, logData.ppIsHostile, logData.ppChance, logData.ppDifficulty, logData.ppEmpty, logData.ppResult, logData.ppClassString, logData.ppClass = GetGameCameraPickpocketingBonusInfo()
	
	logData.level = GetUnitLevel(unitTag)
	logData.gender = GetUnitGender(unitTag)
	logData.class = GetUnitClass(unitTag)   	-- Empty?
	logData.race = GetUnitRace(unitTag)			-- Empty?
	logData.difficulty = GetUnitDifficulty(unitTag)
		
	uespLog.AppendDataToLog("all", logData, uespLog.GetLastTargetData(), uespLog.GetTimeData())
end


function uespLog.GetAllianceShortName (allianceIndex)
	if (uespLog.ALLIANCE_SHORT_NAMES[allianceIndex] == nil) then return "??" end
	return uespLog.ALLIANCE_SHORT_NAMES[allianceIndex]
end


uespLog.SHORT_ALLIANCE_COLORED_NAMES = { }

uespLog.ALLIANCE_COLORS = 
{
	
    [ALLIANCE_ALDMERI_DOMINION] = ZO_ColorDef:New(GetInterfaceColor(INTERFACE_COLOR_TYPE_ALLIANCE, ALLIANCE_ALDMERI_DOMINION)),
    [ALLIANCE_EBONHEART_PACT] = ZO_ColorDef:New(GetInterfaceColor(INTERFACE_COLOR_TYPE_ALLIANCE, ALLIANCE_EBONHEART_PACT)),
    [ALLIANCE_DAGGERFALL_COVENANT] = ZO_ColorDef:New(GetInterfaceColor(INTERFACE_COLOR_TYPE_ALLIANCE, ALLIANCE_DAGGERFALL_COVENANT)),
}


function GetColoredAllianceShortName(alliance)
    local coloredName = SHORT_ALLIANCE_COLORED_NAMES[alliance]
	
    if (coloredName == nil) then
        local color = ZO_ColorDef:New(GetInterfaceColor(INTERFACE_COLOR_TYPE_ALLIANCE, alliance))
        SHORT_ALLIANCE_COLORED_NAMES[alliance] = color:Colorize(GetAllianceShortName(alliance))
        return SHORT_ALLIANCE_COLORED_NAMES[alliance]
    end
	
    return coloredName
end


function uespLog.GetAllianceColoredName (alliance, name)
    local color = uespLog.ALLIANCE_COLORS[alliance]
	
    if (color == nil) then 
		color = ZO_ColorDef:New(0.75, 0.75, 0.75, 1)
	end
	
    return color:Colorize(name) .. "|r"
end


function uespLog.OnArtifactControlState (eventCode, artifactName, keepId, playerName, playerAlliance, controlEvent, controlState, campaignId)
	local msg = ""
	
	if (not uespLog.IsPvpUpdate()) then return end
	
	msg = msg .. tostring(artifactName) .. " changed state by " .. tostring(playerName) .. "[" .. uespLog.GetAllianceShortName(playerAlliance) .. "]."
	uespLog.MsgColor(uespLog.pvpColor, msg)
end


function uespLog.OnCaptureAreaStatus (eventCode, keepId, objectiveId, battlegroundContext, capturePoolValue, capturePoolMax, capturingPlayers, contestingPlayers, owningAlliance)
	local msg = ""
	
	if (not uespLog.IsPvpUpdate()) then return end
	
	--local objName, ovbjType, objState, param1, param2 = GetAvAObjectiveInfo(keepId, objectiveId, battlegroundContext)
	local name = GetKeepName(keepId)
	local alliance = GetKeepAlliance(keepId, battlegroundContext)
	
	if (capturePoolValue ~= 100) then		
		msg = tostring(name) .. " capture at "..tostring(capturePoolValue).. "% by "..uespLog.GetAllianceShortName(owningAlliance) .. "."
		uespLog.MsgColor(uespLog.pvpColor, msg)
	end
end


function uespLog.OnCoronateEmpererNotification  (eventCode, campaignId, emperorName, emperorAlliance)
	local msg = ""
	
	if (not uespLog.IsPvpUpdate()) then return end
	if (GetCurrentCampaignId() ~= campaignId) then return end
	
	msg = tostring(emperorName) .. "["..tostring(uespLog.GetAllianceShortName(emperorAlliance)).."] was crowned Emperor!"
	uespLog.MsgColor(uespLog.pvpColor, msg)
end


uespLog.ARTIFACT_EVENT_DESCRIPTIONS =
{
	[OBJECTIVE_CONTROL_EVENT_CAPTURED] = function(artifactName, keepId, playerName, alliance, allianceName, campaignId)
											return zo_strformat("<<2>> has secured <<3>> at <<4>>", playerName, allianceName, artifactName, GetKeepName(keepId)), soundId
										end,
														
	[OBJECTIVE_CONTROL_EVENT_ASSAULTED] = function(artifactName, keepId, playerName, alliance, allianceName, campaignId)
											return zo_strformat("<<3>> is under attack!", playerName, allianceName, artifactName, GetKeepName(keepId)), soundId
										end,

}



function uespLog.OnObjectiveControlState (eventCode, objectiveKeepId, objectiveObjectiveId, battlegroundContext, objectiveName, objectiveType, objectiveControlEvent, objectiveControlState, objectiveParam1, objectiveParam2)
	local msg = ""
	
	if (not uespLog.IsPvpUpdate()) then return end
	
	--uespLog.DebugExtraMsg("OnObjectiveControlState: "..tostring(objectiveKeepId)..", "..tostring(objectiveObjectiveId)..", "..tostring(battlegroundContext)..", "..tostring(objectiveName)..", "..tostring(objectiveType)..", "..tostring(objectiveControlEvent)..", "..tostring(objectiveControlState)..", "..tostring(objectiveParam1)..", "..tostring(objectiveParam2)..", ")	
	
	local name = GetKeepName(objectiveKeepId)
	local alliance = GetKeepAlliance(objectiveKeepId, battlegroundContext)
	local objName, objType, objState = GetObjectiveInfo(objectiveKeepId, objectiveObjectiveId, battlegroundContext)
	local currentCampaignId = GetCurrentCampaignId()
	local colorName = uespLog.GetAllianceColoredName(alliance, objectiveName.."["..uespLog.GetAllianceShortName(alliance).."]")
	
	local eventHandler = uespLog.ARTIFACT_EVENT_DESCRIPTIONS[objectiveControlEvent]
	
    if (eventHandler) then
        msg = eventHandler(colorName.."|c"..uespLog.pvpColor, objectiveKeepId, "", "", objectiveControlEvent, currentCampaignId)
	else
		--uespLog.DebugExtraMsg("No handler for event: "..tostring(objectiveControlEvent))
		uespLog.DebugExtraMsg("PVP control state "..tostring(objectiveControlEvent) .. " for "..tostring(objectiveName))
    end
	
	if (eventDesc ~= nil and eventDesc ~= "") then
		msg = tostring(eventDesc)
		uespLog.MsgColor(uespLog.pvpColor, msg)
	end
	
end


uespLog.PrevKeepAlliance = {}


function uespLog.OnAssignedCampaignChanged(eventCode, newCampaignId)
	--uespLog.DebugMsg("Campaign changed!")
	uespLog.PrevKeepAlliance = {}
end


function uespLog.OnKeepAllianceOwnerChanged (eventCode, keepId, battlegroundContext, owningAlliance)
	local msg = ""
	if (not uespLog.IsPvpUpdate()) then return end
	
	local name = GetKeepName(keepId)
	local alliance = GetKeepAlliance(keepId, battlegroundContext)
	local oldAlliance = uespLog.PrevKeepAlliance[keepId] or 0
	local keepName = uespLog.GetAllianceColoredName(oldAlliance, tostring(name))
	
	msg = keepName.."|c"..uespLog.pvpColor.." changed ownership to "..GetColoredAllianceName(owningAlliance).."."
	uespLog.MsgColor(uespLog.pvpColor, msg)
	
	uespLog.PrevKeepAlliance[keepId] = alliance
end


function uespLog.OnKeepResourceUpdate (eventCode, keepId)
	local msg = ""
	if (not uespLog.IsPvpUpdate()) then return end
	
	msg = "Resource update for keep "..tostring(keepId) .. "."
	uespLog.MsgColor(uespLog.pvpColor, msg)
end


function uespLog.OnKeepUnderAttack (eventCode, keepId, battlegroundContext, underAttack)
	local msg = ""
	if (not uespLog.IsPvpUpdate()) then return end
	
	local name = GetKeepName(keepId)
	local alliance = GetKeepAlliance(keepId, battlegroundContext)
	local colorName = uespLog.GetAllianceColoredName(alliance, name.."["..uespLog.GetAllianceShortName(alliance).."]")
	
	if (underAttack) then
		msg = colorName.."|c"..uespLog.pvpColor.." is under attack!".."|r"
		uespLog.PrevKeepAlliance[keepId] = alliance
	else
		msg = colorName.."|c"..uespLog.pvpColor.." is no longer under attack.".."|r"
	end
	
	uespLog.MsgColor(uespLog.pvpColor, msg)
end


function uespLog.OnKeepGateStateChanged (eventCode, keepId, open)
	local msg = ""
	if (not uespLog.IsPvpUpdate()) then return end
	
	local name = GetKeepName(keepId)
	local alliance = GetKeepAlliance(keepId, battlegroundContext)
	local colorName = uespLog.GetAllianceColoredName(alliance, name.."["..uespLog.GetAllianceShortName(alliance).."]")
	
	if (underAttack) then
		msg = colorName.."|c"..uespLog.pvpColor.." is now open!".."|r"
	else
		msg = colorName.."|c"..uespLog.pvpColor.." is now closed!".."|r"
	end
	
	uespLog.MsgColor(uespLog.pvpColor, msg)
end


function uespLog.OnGuildKeepClaimUpdated (eventCode, keepId, battlegroundContext)
	local msg = ""
	if (not uespLog.IsPvpUpdate()) then return end
	
	local name = GetKeepName(keepId)
	local alliance = GetKeepAlliance(keepId, battlegroundContext)
	local colorName = uespLog.GetAllianceColoredName(alliance, name.."["..uespLog.GetAllianceShortName(alliance).."]")
	
	msg = colorName.."|c"..uespLog.pvpColor.." ownership was changed.".."|r"
	uespLog.MsgColor(uespLog.pvpColor, msg)
end


SLASH_COMMANDS["/uesppvp"] = function (cmd)
	cmd = string.lower(cmd)

	if (cmd == "on") then
		uespLog.SetPvpUpdate(true)
		uespLog.Msg("PVP update is now ON!")
	elseif (cmd == "off") then
		uespLog.SetPvpUpdate(false)
		uespLog.Msg("PVP update is now OFF!")
	elseif (cmd == "showfights") then
		uespLog.ShowPvpFights()
	else
		uespLog.Msg("PVP update is currently "..uespLog.BoolToOnOff(uespLog.IsPvpUpdate()))
		uespLog.Msg("    Use /uesppvp on/off to change setting")
	end
	
end


uespLog.KnownLocalBattles = { }
uespLog.KNOWN_LOCAL_BATTLES_DELETETIMEMS = 300000


uespLog.PINTYPE_BATTLE_NAMES = {
	[83] = "Large Keep Attack",
	[84] = "Small Keep Attack",
	[96] = "Small EP vs AD battle",
	[97] = "Medium EP vs AD battle",
	[98] = "Large EP vs AD battle",
	[99] = "Small AD vs DC battle",
	[100] = "Medium AD vs DC battle",
	[101] = "Large AD vs DC battle",
	[102] = "Small DC vs EP battle",
	[103] = "Medium DC vs EP battle",
	[104] = "Large DC vs EP battle",
}


function uespLog.FindClosestKeep(nx, ny)
	local numAvaObj = GetNumAvAObjectives()
	local bestIndex = -1
	local bestDistance = 100000
	
	for i = 1, numAvaObj do
		local keepId, objId, bgContext = GetAvAObjectiveKeysByIndex(i)
		local pinType, currentX, currentY, contUpdate = GetAvAObjectivePinInfo(keepId, objId, bgContext)
		
		local diffX = nx - currentX
		local diffY = ny - currentY
		local distance = math.sqrt(diffX * diffX + diffY * diffY)
		
		if (distance < bestDistance) then
			bestDistance = distance
			bestIndex = i
		end
	end
	
	local keepId, objId, bgContext = GetAvAObjectiveKeysByIndex(bestIndex)
	local pinType, currentX, currentY, contUpdate = GetAvAObjectivePinInfo(keepId, objId, bgContext)
	local diffX = currentX - nx
	local diffY = currentY - ny
	local angle = math.atan2(diffY, diffX) * 57.29578
	local direction = "?"
	
	if (angle >= -22.5 and angle < 22.5) then
		direction = "E"
	elseif (angle >= 22.5 and angle < 67.5) then
		direction = "NE"
	elseif (angle >= 67.5 and angle < 112.5) then
		direction = "N"
	elseif (angle >= 112.5 and angle < 157.5) then
		direction = "NW"
	elseif (angle >= 157.5 or angle < -157.5) then
		direction = "W"
	elseif (angle >= -157.5 and angle < -112.5) then
		direction = "SW"
	elseif (angle >= -112.5 and angle < -67.5) then
		direction = "S"
	elseif (angle >= -67.5 and angle < -22.5) then
		direction = "SE"
	end
		
	return keepId, objId, bgContext, direction
end


function uespLog.CheckForNewLocalBattles()

	if (not uespLog.IsPvpUpdate()) then return end
	uespLog.DeleteOldKnownLocalBattles()
	
	uespLog.FindPvpFights(false)
	
	local killNum = GetNumKillLocations()
	
	for i = 1, killNum do
		local pinType, currentX, currentY = GetKillLocationPinInfo(i)
		
		if (pinType ~= nil) then
			if ((pinType >= 83 and pinType <= 83) or (pinType >= 96 and pinType <= 104)) then
				local uniqueId = math.floor(math.floor((currentX or 0) * 1000)*1000 + math.floor((currentY or 0)*1000))
			
				if (uespLog.KnownLocalBattles[uniqueId] == nil) then            
					uespLog.KnownLocalBattles[uniqueId] = GetGameTimeMilliseconds()
				
					local coorStr = string.format("(%0.3f, %0.3f)", currentX, currentY)
					local pinName = uespLog.PINTYPE_BATTLE_NAMES[pinType] or "battle"
					local keepId, objId, bgContext, direction = uespLog.FindClosestKeep(currentX, currentY)
					local name = GetKeepName(keepId)
					local alliance = GetKeepAlliance(keepId, bgContext)
					local colorName = uespLog.GetAllianceColoredName(alliance, name.."["..uespLog.GetAllianceShortName(alliance).."]")
					local msg = "" .. pinName .. " "..direction.." of "..colorName.."|c"..uespLog.pvpColor.." "..coorStr.."|r"
					--local msg = "Found " .. pinName .. ", "..coorStr.." in current map"
					
					uespLog.MsgColor(uespLog.pvpColor, msg)
				end
			end
		end
	end
			
end


function uespLog.FindPvpFights(showAll)
	local killNum = GetNumKillLocations()
	local outputNum = 0
	
	for i = 1, killNum do
		local pinType, currentX, currentY = GetKillLocationPinInfo(i)
		
		if (pinType ~= nil) then
			if ((pinType >= 83 and pinType <= 83) or (pinType >= 96 and pinType <= 104)) then
				local uniqueId = math.floor(math.floor((currentX or 0) * 1000)*1000 + math.floor((currentY or 0)*1000))
			
				if (showAll or uespLog.KnownLocalBattles[uniqueId] == nil) then            
				
					if (not showAll) then
						uespLog.KnownLocalBattles[uniqueId] = GetGameTimeMilliseconds()
					end
				
					local coorStr = string.format("(%0.3f, %0.3f)", currentX, currentY)
					local pinName = uespLog.PINTYPE_BATTLE_NAMES[pinType] or "battle"
					local keepId, objId, bgContext, direction = uespLog.FindClosestKeep(currentX, currentY)
					local name = GetKeepName(keepId)
					local alliance = GetKeepAlliance(keepId, bgContext)
					local colorName = uespLog.GetAllianceColoredName(alliance, name.."["..uespLog.GetAllianceShortName(alliance).."]")
					local msg = "" .. pinName .. " "..direction.." of "..colorName.."|c"..uespLog.pvpColor.." "..coorStr.."|r"
					--local msg = "Found " .. pinName .. ", "..coorStr.." in current map"
					
					uespLog.MsgColor(uespLog.pvpColor, msg)
					outputNum = outputNum + 1
				end
			end
		end
	end
	
	if (showAll and outputNum == 0) then
		uespLog.MsgColor(uespLog.pvpColor, "No PVP fights found!")
	end
			
end


function uespLog.DeleteOldKnownLocalBattles()
	local idsToDelete = { }
	local CurrentTime = GetGameTimeMilliseconds()
	
	for id, knownBattleTime in pairs(uespLog.KnownLocalBattles) do
	
		if (knownBattleTime == nil) then
			idsToDelete[#idsToDelete + 1] = id
		elseif (CurrentTime - knownBattleTime >= uespLog.KNOWN_LOCAL_BATTLES_DELETETIMEMS) then
			idsToDelete[#idsToDelete + 1] = id
		end
	end
	
	for i = 1, #idsToDelete do
		uespLog.KnownLocalBattles[idsToDelete[i]] = nil
	end
	
end


function uespLog.ShowPvpFights()
	local killNum = GetNumKillLocations()
	
	if (killNum == 0) then
		uespLog.MsgColor(uespLog.pvpColor, "No PVP fights found!")
	else
		--uespLog.MsgColor(uespLog.pvpColor, tostring(killNum).." PVP fights found!")
		uespLog.FindPvpFights(true)
	end
end


function uespLog.LoreBookCmd(cmd)
	cmd = string.lower(cmd)
	
	if (cmd == 'on') then
		uespLog.SetLoreBookMsgFlag(true)
		uespLog.Msg("Set LoreBook to: "..uespLog.BoolToOnOff(uespLog.GetLoreBookMsgFlag()) )
	elseif (cmd == 'off') then
		uespLog.SetLoreBookMsgFlag(false)
		uespLog.Msg("Set LoreBook to: "..uespLog.BoolToOnOff(uespLog.GetLoreBookMsgFlag()) )
	elseif (cmd == '') then
		uespLog.Msg("Current LoreBook Setting is: "..uespLog.BoolToOnOff(uespLog.GetLoreBookMsgFlag()) )
	else
		uespLog.Msg("Turns on/off the 'LoreBook Learned' messages.")
		uespLog.Msg(".     Use the format: /uesplorebook [on/off]")
		uespLog.Msg(".     Current Setting is: "..uespLog.BoolToOnOff(uespLog.GetLoreBookMsgFlag()) )
	end
		
end


-- SLASH_COMMANDS["/uesplorebook"] = uespLog.LoreBookCmd


SLASH_COMMANDS["/uespchardata"] = function (cmd)
	cmds = uespLog.SplitCommands(cmd)
	cmd = string.lower(cmds[1] or "")
		
	if (cmd == 'on') then
		uespLog.SetAutoSaveCharData(true)
		uespLog.Msg("Set auto saving of character data to: "..uespLog.BoolToOnOff(uespLog.GetAutoSaveCharData()) )
	elseif (cmd == 'off') then
		uespLog.SetAutoSaveCharData(false)
		uespLog.Msg("Set auto saving of character data to: "..uespLog.BoolToOnOff(uespLog.GetAutoSaveCharData()) )
	elseif (cmd == 'zonesave') then
		local cmd2 = string.lower(cmds[2] or "")
		
		if (cmd2 == 'on') then
			uespLog.SetAutoSaveZoneCharData(true)
		elseif (cmd2 == 'off') then
			uespLog.SetAutoSaveZoneCharData(false)
		end
		
		uespLog.Msg("Auto zone saving of character data is "..uespLog.BoolToOnOff(uespLog.GetAutoSaveZoneCharData()) )
	elseif (cmd == 'save') then
		
		if (uespLog.SaveCharData()) then
			uespLog.Msg("Manually saved the current character data.")
		else
			uespLog.Msg("Error saving the current character data!")
		end
		
	elseif (cmd == 'extended') then
		local cmd2 = string.lower(cmds[2] or "")
		
		if (cmd2 == "on") then
			uespLog.SetSaveExtendedCharData(true)
		elseif (cmd2 == "off") then
			uespLog.SetSaveExtendedCharData(false)
		else
			uespLog.Msg("Turning extended character data on enables the saving of:")
			uespLog.Msg(".      Achievements, Books, Quests, Collectibles, Recipes")
			uespLog.Msg("Turning this off can reduce the size of the saved variable file.")
		end

		uespLog.Msg("Extended character data is currently "..uespLog.BoolToOnOff(uespLog.GetSaveExtendedCharData()) )
	else
		uespLog.Msg("Turns on/off the automatic saving of character data. Use the format:")
		uespLog.Msg(".     /uespchardata [on/off]                     Turn automatic saving on/off")
		uespLog.Msg(".     /uespchardata save                        Manually save the character data")
		uespLog.Msg(".     /uespchardata extended [on/off]    Save extended character data")
		uespLog.Msg(".          Extended saving is currently "..uespLog.BoolToOnOff(uespLog.GetSaveExtendedCharData()) )
		uespLog.Msg(".          Automatic saving is currently "..uespLog.BoolToOnOff(uespLog.GetAutoSaveCharData()) )
		--uespLog.Msg(".          Automatic saving when zoning is "..uespLog.BoolToOnOff(uespLog.GetAutoSaveZoneCharData()) )
	end
		
end


function uespLog.SplitCommands(cmd)
	local cmds = {}
	
	for word in cmd:gmatch("%S+") do table.insert(cmds, word) end
	
	return cmds, (cmds[1] or ""):lower()
end


SLASH_COMMANDS["/uespquestitem"] = function(cmd)
	-- |H1:quest_item:QUESTITEMID|h|h
	-- questItemId
	local cmds = uespLog.SplitCommands(cmd)
	local questItemId = tonumber(cmds[1]) or 0
	
	if (questItemId <= 0) then
		return
	end
	
	local questItemLink = "|H1:quest_item:"..tostring(questItemId).."|h|h"
	uespLog.Msg("UESP: Made quest item link ".. questItemLink)
	ZO_PopupTooltip_SetLink(questItemLink)	
	
	uespLog.Msg("UESP:    Name = ".. tostring(GetItemLinkName(questItemLink)))
	uespLog.Msg("UESP:    Desc = ".. tostring(GetItemLinkFlavorText(questItemLink)))
	
end


SLASH_COMMANDS["/uesptrait"] = function(cmd)
	local cmds = uespLog.SplitCommands(cmd)
	local cmd1 = tostring(cmds[1]):lower()
	
	if (cmd1 == "blacksmith" or cmd1 == "blacksmithing" or cmd1 == "black") then
		uespLog.ShowTraitInfo(CRAFTING_TYPE_BLACKSMITHING)
	elseif (cmd1 == "clothing" or cmd1 == "clothier" or cmd1 == "cloth") then
		uespLog.ShowTraitInfo(CRAFTING_TYPE_CLOTHIER)
	elseif (cmd1 == "woodwork" or cmd1 == "woodworking" or cmd1 == "wood" or cmd1 == "woodworker") then
		uespLog.ShowTraitInfo(CRAFTING_TYPE_WOODWORKING)
	elseif (cmd1 == "jewelry" or cmd1 == "jewelrycrafting" or cmd1 == "jewelry crafting" or cmd1 == "jewel") then
		uespLog.ShowTraitInfo(CRAFTING_TYPE_JEWELRYCRAFTING)
	else
		uespLog.ShowTraitInfo(CRAFTING_TYPE_CLOTHIER)
		uespLog.ShowTraitInfo(CRAFTING_TYPE_BLACKSMITHING)
		uespLog.ShowTraitInfo(CRAFTING_TYPE_JEWELRYCRAFTING)
		uespLog.ShowTraitInfo(CRAFTING_TYPE_WOODWORKING)		
	end
	
end


function uespLog.implode(tab, delim)
    local output = ""
	local isFirst = true
	local strDelim = tostring(delim)
	
	if (type(tab) ~= "table") then
		return tostring(tab)
	end
	
    for _, v in pairs(tab) do
	
		if (not isFirst) then
			output = output .. strDelim
		end
		
        output = output .. tostring(v)
		isFirst = false
    end
	
    return output
end


function uespLog.implodeKeys(tab, delim)
    local output = ""
	local isFirst = true
	local strDelim = tostring(delim)
	
	if (type(tab) ~= "table") then
		return tostring(tab)
	end
	
    for k, v in pairs(tab) do
	
		if (not isFirst) then
			output = output .. strDelim
		end
		
        output = output .. tostring(k)
		isFirst = false
    end
	
    return output
end


function uespLog.implodeOrder(tab, delim, startIndex)
	local output = ""
	local isFirst = true
	local strDelim = tostring(delim)
	
	startIndex = startIndex or 0
	
    for i, v in ipairs(tab) do
	
		if (i >= startIndex) then
		
			if (not isFirst) then
				output = output .. strDelim
			end
			
			output = output .. tostring(v)
			isFirst = false
		end
    end
	
    return output
end


function uespLog.ShowTraitInfo(craftingType)
	local TradeskillName = uespLog.GetCraftingName(craftingType)
	local numLines = GetNumSmithingResearchLines(craftingType)
	local totalAllTraits = 0
	local totalKnownTraits = 0
	
	if (numLines == 0) then
		uespLog.MsgColor(uespLog.researchColor, TradeskillName.." doesn't have any research lines available!")
		return
	end
	
	uespLog.MsgColor(uespLog.researchColor, TradeskillName.." Trait Info:")
	
	for researchLineIndex = 1, numLines do
		local slotName, _, numTraits, _ = GetSmithingResearchLineInfo(craftingType, researchLineIndex)
		local knownTraits = {}
		local unknownTraits = {}
		local totalTraits = 0
		local knownTraitCount = 0
		local unknownTraitCount = 0
		
		for traitIndex = 1, numTraits do
			local duration, timeRemainingSecs = GetSmithingResearchLineTraitTimes(craftingType, researchLineIndex, traitIndex)
			local traitType, _, known = GetSmithingResearchLineTraitInfo(craftingType, researchLineIndex, traitIndex)
			local traitName = uespLog.GetItemTraitName(traitType)
			totalTraits = totalTraits + 1
			
			if (known) then
				knownTraits[traitIndex] = traitName
				knownTraitCount = knownTraitCount + 1
			elseif (duration ~= nil ) then  -- Being researched
				knownTraits[traitIndex] = "["..traitName.."]"
				unknownTraitCount = unknownTraitCount + 1
			else
				unknownTraits[traitIndex] = traitName
				unknownTraitCount = unknownTraitCount + 1
			end
		end
		
		totalAllTraits = totalAllTraits + totalTraits
		totalKnownTraits = totalKnownTraits + knownTraitCount
		
		if (unknownTraitCount == 0) then
			uespLog.MsgColor(uespLog.researchColor, ".     "..tostring(slotName)..": All traits known")
		elseif (knownTraitCount == 0) then
			uespLog.MsgColor(uespLog.researchColor, ".     "..tostring(slotName)..": No traits known")
		else
			local knownString = uespLog.implode(knownTraits, ", ")
			uespLog.MsgColor(uespLog.researchColor, ".     "..tostring(slotName).." ("..tostring(knownTraitCount).."/"..tostring(totalTraits).."): "..knownString)
		end
	end
	
	uespLog.MsgColor(uespLog.researchColor, ".          "..tostring(totalKnownTraits).." of "..tostring(totalAllTraits).." traits known")
	
	return totalKnownTraits, totalAllTraits
end


function uespLog.trim(s)

	if (s == nil) then
		return ""
	end
	
	return (s:gsub("^%s*(.-)%s*$", "%1"))
end


function uespLog.IsItemUsable(bagId, slotIndex)
	local itemLink = GetItemLink(bagId, slotIndex)
	local linkId = tostring(bagId) .. ":" .. tostring(slotIndex)
	
	uespLog.lastItemLinkTime = GetGameTimeMilliseconds()
	uespLog.lastItemLinkUsed = itemLink
	uespLog.lastItemLinkUsed_BagId = bagId
	uespLog.lastItemLinkUsed_SlotIndex = slotIndex
	
	if (itemLink ~= "") then
		uespLog.lastItemLinkUsed_itemLinks[linkId] = itemLink
		uespLog.lastItemLinkUsed_Name = GetItemLinkName(itemLink)
		uespLog.lastItemLinkUsed_itemNames[linkId] = uespLog.lastItemLinkUsed_Name
	end
	
	--uespLog.DebugExtraMsg("IsItemUsable: "..tostring(bagId)..", "..tostring(slotIndex)..", "..tostring(itemLink))
	
	return uespLog.Old_IsItemUsable(bagId, slotIndex)
end	


function uespLog.ActionButton_HandleRelease(self)
	local slotNum = self:GetSlot() or 0
	local buttonType  = self:GetButtonType()
	local slotType = GetSlotType(slotNum)
	
		-- Check for quickslot actions
	if (slotType == ABILITY_SLOT_TYPE_QUICKSLOT) then
		uespLog.OnQuickSlotUsed(slotNum)
	end
	
		-- Ultimate activation, might bar swap
	if (slotType == 1 and slotNum == 8) then
		uespLog.SaveActionBarForCharData()
		uespLog.SaveStatsForCharData()
	end
	
	uespLog.DebugExtraMsg("uespLog.ActionButton_HandleRelease "..tostring(slotNum)..", "..tostring(buttonType)..", "..tostring(slotType))
	
	return uespLog.Old_ActionButton_HandleRelease(self)
end


function uespLog.OnQuickSlotUsed(slotNum)
	local itemLink = GetSlotItemLink(slotNum)
	local itemType = GetItemLinkItemType(itemLink)
	
	if (itemType == ITEMTYPE_FOOD or itemType == ITEMTYPE_DRINK) then
		uespLog.OnEatDrinkItem(itemLink)
	end
	
	uespLog.lastItemLinkUsed = ""
	uespLog.lastItemLinkUsed_BagId = -1
	uespLog.lastItemLinkUsed_SlotIndex = -1
	uespLog.lastItemLinkUsed_itemLinks = {}
	uespLog.lastItemLinkUsed_Name = ""
	uespLog.lastItemLinkUsed_itemNames = {}
end


function uespLog.Quit()
	uespLog.OnLogoutAutoSaveCharData()
	uespLog.UpdateTrackLootTime()
	
	return uespLog.Old_Quit()
end


function uespLog.Logout()
	uespLog.OnLogoutAutoSaveCharData()
	uespLog.UpdateTrackLootTime()
	
	return uespLog.Old_Logout()
end


function uespLog.ReloadUI(guiName)
	uespLog.OnLogoutAutoSaveCharData()
	uespLog.UpdateTrackLootTime()
	
	return uespLog.Old_ReloadUI(guiName)
end


function uespLog.OnQuestToolChanged(eventCode, journalIndex, toolIndex)
	uespLog.DebugExtraMsg("UESP: OnQuestToolChanged "..tostring(journalIndex).." "..tostring(toolIndex))
	--GetQuestItemInfo(number journalQuestIndex, number stepIndex, number conditionIndex)
	--Returns: textureName iconFilename, number stackCount, string name, number questItemId
	--GetQuestItemTooltipInfo(number journalQuestIndex, number stepIndex, number conditionIndex)
	--Returns: string header, string itemName, string tooltipText
end


function uespLog.CheckQuestItems(journalIndex, questName)
	local numSteps = GetJournalQuestNumSteps(journalIndex)
	local numTools = GetQuestToolCount(journalIndex)
	local stepIndex
	local condIndex
	
	uespLog.DebugExtraMsg("Checking quest items for quest "..tostring(questName).." ("..tostring(journalIndex)..")")
		
	for stepIndex = 1, numSteps do
		local numConditions = GetJournalQuestNumConditions(journalIndex, stepIndex)
		
		for condIndex = 1, numConditions do
			local itemLink = GetQuestItemLink(journalIndex, stepIndex, condIndex)
			
			if (itemLink ~= "") then
				uespLog.LogQuestItemLink(journalIndex, stepIndex, condIndex, questName)
			end
		end
	end
	
	for toolIndex = 1, numTools do
		local itemLink = GetQuestToolLink(journalIndex, toolIndex)
		
		if (itemLink ~= "") then
			uespLog.LogQuestToolItemLink(journalIndex, toolIndex, questName)
		end
	end

end


function uespLog.LogQuestItemLink(journalIndex, stepIndex, conditionIndex, questName)
	local itemLink = GetQuestItemLink(journalIndex, stepIndex, conditionIndex)
	local questDataId = uespLog.GetQuestUniqueDataId(journalIndex)
	local questStageIndex = uespLog.GetCharQuestStageData()[questDataId] or nil
	local questUniqueId = uespLog.GetCharQuestUniqueIds()[questDataId] or 0
	local logData = {}
	
	if (itemLink == "") then
		return
	end
	
	logData.event = "QuestItem"
	logData.itemLink = itemLink
	logData.journalIndex = journalIndex
	logData.stepIndex = stepIndex
	logData.conditionIndex = conditionIndex
	logData.questName = questName
	logData.uniqueId = questUniqueId
	logData.stageIndex = questStageIndex
	
	logData.texture, logData.stackCount, logData.name1, logData.questId = GetQuestItemInfo(journalIndex, stepIndex, conditionIndex)
	logData.header, logData.name, logData.desc = GetQuestItemTooltipInfo(journalIndex, stepIndex, conditionIndex)
	logData.duration = GetQuestItemCooldownInfo(journalIndex, stepIndex, conditionIndex)
	
	uespLog.AppendDataToLog("all", logData, uespLog.GetTimeData())
	
	itemLink = GetQuestItemLink(journalIndex, stepIndex, conditionIndex, LINK_STYLE_BRACKETS)
	uespLog.DebugExtraMsg("UESP: Logged quest item link "..tostring(itemLink))
end


function uespLog.LogQuestToolItemLink(journalIndex, toolIndex, questName)
	local itemLink = GetQuestToolLink(journalIndex, toolIndex)
	local questDataId = uespLog.GetQuestUniqueDataId(journalIndex)
	local questStageIndex = uespLog.GetCharQuestStageData()[questDataId] or nil
	local questUniqueId = uespLog.GetCharQuestUniqueIds()[questDataId] or 0
	local logData = {}
	
	if (itemLink == "") then
		return
	end
	
	logData.event = "QuestItem"
	logData.itemLink = itemLink
	logData.journalIndex = journalIndex
	logData.toolIndex = toolIndex
	logData.questName = questName
	logData.uniqueId = questUniqueId
	logData.stageIndex = questStageIndex
		
	logData.texture, logData.stackCount, logData.isUsuable, logData.name1, logData.questId = GetQuestToolInfo(journalIndex, toolIndex)
	logData.header, logData.name, logData.desc = GetQuestToolTooltipInfo(journalIndex, toolIndex)
	
	uespLog.AppendDataToLog("all", logData, uespLog.GetTimeData())
	
	itemLink = GetQuestToolLink(journalIndex, toolIndex, LINK_STYLE_BRACKETS)
	uespLog.DebugExtraMsg("UESP: Logged quest tool item link "..tostring(itemLink))
end


function uespLog.OnActionSlotAbilityUsed(event, slotIndex)
	--uespLog.DebugExtraMsg("OnActionSlotAbilityUsed::"..tostring(slotIndex))
end


function uespLog.GetPlayerStatusString(status)
	return GetString(SI_PLAYERSTATUS1 + tonumber(status) - 1) or "Unknown"
end


function uespLog.AfkCommand(cmd)
	local status = GetPlayerStatus()
	cmd = string.lower(cmd or "")
	
	if (cmd == "on") then
		SelectPlayerStatus(PLAYER_STATUS_AWAY)
	elseif (cmd == "off") then
		SelectPlayerStatus(PLAYER_STATUS_ONLINE)
	elseif (cmd == "status" or cmd == "show") then
		-- Do nothing
	elseif (cmd == "away") then
		SelectPlayerStatus(PLAYER_STATUS_AWAY)
	elseif (cmd == "online") then
		SelectPlayerStatus(PLAYER_STATUS_ONLINE)
	elseif (cmd == "dnd" or cmd == "do not disturb" or cmd == "donotdisturb") then
		SelectPlayerStatus(PLAYER_STATUS_DO_NOT_DISTURB)
	elseif (cmd == "offline") then
		SelectPlayerStatus(PLAYER_STATUS_OFFLINE)
	elseif (status == PLAYER_STATUS_ONLINE) then
		SelectPlayerStatus(PLAYER_STATUS_AWAY)
	else
		SelectPlayerStatus(PLAYER_STATUS_ONLINE)
	end
	
	status = GetPlayerStatus()
	local statusMsg = uespLog.GetPlayerStatusString(status)
	uespLog.Msg("Player status is now "..statusMsg)
end


function uespLog.AwayCommand(cmd)
	uespLog.AfkCommand("away")
end


function uespLog.BackCommand(cmd)
	uespLog.AfkCommand("online")
end


uespLog.speedMeasure = false
uespLog.speedMeasureDeltaTime = 1
uespLog.speedLastX = nil
uespLog.speedLastY = nil
uespLog.speedLastZone = nil
uespLog.speedLastTimestamp = nil
uespLog.speedFirstTimestamp = nil
uespLog.speedTotalDelta = 0
uespLog.speedMagicFactor = 1000000


function uespLog.SpeedCommand(cmd)
	local cmds, firstCmd = uespLog.SplitCommands(cmd)
	
	if (firstCmd == "on") then
		uespLog.SpeedMeasureEnable()
	elseif (firstCmd == "off") then
		uespLog.SpeedMeasureDisable()
	elseif (uespLog.speedMeasure) then
		uespLog.Msg("Speed measurement is on.")
	else
		uespLog.Msg("Speed measurement is off.")
	end
	
end


function uespLog.SpeedMeasureEnable()

	if (uespLog.speedMeasure) then
		uespLog.Msg("Speed measurement is already on!")
		return
	end
		
	uespLog.speedMeasure = true
	uespLog.Msg("Turned speed measurements on...")
	uespLog.RecordSpeedParameters()
	zo_callLater(uespLog.SpeedMeasureCallback, uespLog.speedMeasureDeltaTime*1000)
end


function uespLog.SpeedMeasureCallback()

	if (not uespLog.speedMeasure) then
		return
	end
	
	local speed = uespLog.RecordSpeedParameters() * uespLog.speedMagicFactor
	local avgSpeed = uespLog.speedTotalDelta / (uespLog.speedLastTimestamp - uespLog.speedFirstTimestamp) * uespLog.speedMagicFactor
	
	if (speed ~= nil and speed ~= 0) then
		uespLog.Msg("Speed: "..string.format("%.2f", speed).." u/s (average = "..string.format("%.2f", avgSpeed).." u/s)")
	end
	
	zo_callLater(uespLog.SpeedMeasureCallback, uespLog.speedMeasureDeltaTime*1000)
end


function uespLog.SpeedMeasureDisable()

	if (not uespLog.speedMeasure) then
		uespLog.Msg("Speed measurement is already off!")
		return
	end
	
	uespLog.speedMeasure = false
	uespLog.speedLastX = nil
	uespLog.speedLastY = nil
	uespLog.speedLastZone = nil
	uespLog.speedLastTimestamp = nil
	uespLog.speedFirstTimestamp = nil
	uespLog.speedTotalTime = 0
	uespLog.speedTotalDelta = 0
	
	uespLog.Msg("Turned speed measurements off...")
end


function uespLog.RecordSpeedParameters()
	local x, y, heading, zone = GetMapPlayerPosition("player")
	local timestamp = GetGameTimeMilliseconds()
	local speed = nil
	
	if (uespLog.speedLastX ~= nil and uespLog.speedLastY ~= nil and uespLog.speedLastZone == zone and uespLog.speedLastTimestamp ~= nil) then
		local deltaX = x - uespLog.speedLastX
		local deltaY = y - uespLog.speedLastY
		local deltaPos = math.sqrt(deltaX*deltaX + deltaY*deltaY)
		local deltaTime = timestamp - uespLog.speedLastTimestamp 
		
		speed = deltaPos / deltaTime
		uespLog.speedTotalDelta = uespLog.speedTotalDelta + deltaPos
	end	
	
	if (uespLog.speedFirstTimestamp == nil) then
		uespLog.speedFirstTimestamp = timestamp
	end
	
	uespLog.speedLastX = x
	uespLog.speedLastY = y
	uespLog.speedLastZone = zone
	uespLog.speedLastTimestamp = timestamp
	
	return speed
end


SLASH_COMMANDS["/uespspeed"] = uespLog.SpeedCommand


function uespLog.BuyPassives(putPointInNextUpgrade, charOnly)
	local numSkillTypes = GetNumSkillTypes()
	local skillType
	local skillIndex
	local abilityIndex
	local purchaseCount = 0
	local nextTimeDelay = 10
	local timeDelayStep = 200
	
	EVENT_MANAGER:UnregisterForEvent("uespLog", EVENT_SKILL_POINTS_CHANGED)
	
	for skillType = 1, numSkillTypes do
		local numSkillLines = GetNumSkillLines(skillType)
		
		for skillIndex = 1, numSkillLines do
			local numSkillAbilities = GetNumSkillAbilities(skillType, skillIndex)
			local _, currentRank = GetSkillLineInfo(skillType, skillIndex)
			
			if (charOnly and not (skillType == 1 or skillType == 7)) then
				break
			end
			
			for abilityIndex = 1, numSkillAbilities do
				local _, _, earnedRank, passive, _, purchase, progressionIndex = GetSkillAbilityInfo(skillType, skillIndex, abilityIndex)
				local level, maxLevel = GetSkillAbilityUpgradeInfo(skillType, skillIndex, abilityIndex)
				local _, _, nextEarnedRank = GetSkillAbilityNextUpgradeInfo(skillType, skillIndex, abilityIndex)
				
				if (passive) then
				
					if (GetAvailableSkillPoints() <= 0) then
						break
					end
				
					if (level == nil) then 
						if (purchase) then
							level = 1
						else
							level = 0 
						end
					end
					
					if (maxLevel == nil) then maxLevel = 1 end
					
					if (nextEarnedRank == nil) then
						nextEarnedRank = earnedRank
					end
					
					if (level < maxLevel and nextEarnedRank <= currentRank) then
						if (putPointInNextUpgrade and level >= 1) then
							zo_callLater(function() PutPointIntoSkillAbility(skillType, skillIndex, abilityIndex, putPointInNextUpgrade) end, nextTimeDelay)
							nextTimeDelay = nextTimeDelay + timeDelayStep
							purchaseCount = purchaseCount + 1
						elseif (not putPointInNextUpgrade and level < 1) then
							zo_callLater(function() PutPointIntoSkillAbility(skillType, skillIndex, abilityIndex, putPointInNextUpgrade) end, nextTimeDelay)
							nextTimeDelay = nextTimeDelay + timeDelayStep
							purchaseCount = purchaseCount + 1
						end
					end
				end
				
			end
			
			if (GetAvailableSkillPoints() <= 0) then
				break
			end
		end
		
		if (GetAvailableSkillPoints() <= 0) then
			break
		end
	end
	
	if (GetAvailableSkillPoints() <= 0) then
		uespLog.Msg(".       No more skill points available!")
	end
	
	if (purchaseCount > 0) then
		zo_callLater(function() uespLog.Msg("Finished purchasing "..purchaseCount.." skills...") end, nextTimeDelay)
		uespLog.Msg("Purchased "..purchaseCount.." passive ranks (wait for message to proceed)!")
	else
		uespLog.Msg("Purchased 0 passive ranks!")
	end
		
	zo_callLater(function () EVENT_MANAGER:RegisterForEvent("uespLog", EVENT_SKILL_POINTS_CHANGED, uespLog.OnSkillPointsChanged) end, nextTimeDelay + 1000)
end


function uespLog.BuyPassiveCommand(cmd)
	local cmds, firstCmd = uespLog.SplitCommands(cmd)
	
	if (firstCmd == "all") then
		uespLog.Msg("Buying 1 rank in all passives previously purchased...")
		uespLog.BuyPassives(true, false)
		return true
	elseif (firstCmd == "first") then
		uespLog.Msg("Buying first rank in all unpurchased passives...")
		uespLog.BuyPassives(false, false)
		return true
	elseif (firstCmd == "char" or firstCmd == "character") then
		local secondCmd = string.lower(cmds[2])
		
		if (secondCmd == "all") then
			uespLog.Msg("Buying 1 rank in character passives previously purchased...")
			uespLog.BuyPassives(true, true)
			return true
		elseif (secondCmd == "first") then
			uespLog.Msg("Buying first rank in unpurchased character passives...")
			uespLog.BuyPassives(false, true)
			return true
		end
		
	end
	
	uespLog.MsgColor(uespLog.warningColor, "Warning: This command purchases one rank of all passives. It is only used to help dump all skill data on the PTS.")
	uespLog.MsgColor(uespLog.warningColor, "If you really want to run it use the following format:")
	uespLog.MsgColor(uespLog.warningColor, ".     /uespbuypassive first           Buy first rank in all passives")
	uespLog.MsgColor(uespLog.warningColor, ".     /uespbuypassive all             Buy next rank in all passives")
	uespLog.MsgColor(uespLog.warningColor, ".     /uespbuypassive char first   Buy first rank in all character passives")
	uespLog.MsgColor(uespLog.warningColor, ".     /uespbuypassive char all     Buy next rank in all character passives")
end

--SLASH_COMMANDS["/uespbuypassive"] = uespLog.BuyPassiveCommand


function uespLog.ZO_Alert(category, soundId, msg, ...)

	if (category == UI_ALERT_CATEGORY_ALERT and msg == SI_ERROR_INVALID_COMMAND) then
		--uespLog.Msg("Warning: Invalid chat command received!")
		--return
	end
	
	return uespLog.Old_ZO_Alert(category, soundId, msg, ...)
end


	-- The native DoCommand() function never appears to be used
function uespLog.DoCommand(text)
    local command, arguments = zo_strmatch(text, "^(/%S+)%s?(.*)")
	
    ZO_Menu_SetLastCommandWasFromMenu(false)
	
    command = zo_strlower(command or "")
    local fn = SLASH_COMMANDS[command]
	
	if(fn) then
        fn(arguments or "")
    else
          if IsInternalBuild() then
				ExecuteChatCommand(text)
          else
				uespLog.MsgColor(uespLog.errorColor, "Warning: Invalid chat command '"..command.."'!")
				--ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, SI_ERROR_INVALID_COMMAND)
          end
    end
	
end


function uespLog.CheckSlashCommand(text)
	local command, arguments = zo_strmatch(text, "^(/%S+)%s?(.*)")
	
    command = zo_strlower(command or "")
    local fn = SLASH_COMMANDS[command]
	
	if (command ~= "" and fn == nil) then
		return false, command
	end
	
	return true, command
end


function uespLog.ZO_ChatTextEntry_Execute(control)

    if control.system:IsAutoCompleteOpen() then
        --control.system:CloseAutoComplete()
    else
		local text = control.system.textEntry:GetText()
		local isValid, command = uespLog.CheckSlashCommand(text)
		
		if (not isValid) then
		 	uespLog.Msg("Warning: Invalid chat command '"..command.."'!")
		end
		
        --control.system:SubmitTextEntry()
    end
	
	 uespLog.Old_ZO_ChatTextEntry_Execute(control)
end


function uespLog.FishingCommand(cmd)
	local cmds, firstCmd = uespLog.SplitCommands(cmd)
	
	if (firstCmd == "on") then
		uespLog.SetFishingFlag(true)
		uespLog.Msg("Fishing features turned on.")
	elseif (firstCmd == "off") then
		uespLog.SetFishingFlag(false)
		uespLog.Msg("Fishing features turned off.")
	else
		uespLog.Msg("Turns fishing related features on/off. Command format is:")
		uespLog.Msg(".       /uespfish [on||off]")
		uespLog.Msg(".   Fishing is currently set to "..uespLog.BoolToOnOff(uespLog.GetFishingFlag())..".")
	end
	
end


SLASH_COMMANDS["/uespfish"] = uespLog.FishingCommand


function uespLog.OnFishingLureCleared(eventCode)
	uespLog.DebugExtraMsg("UESP: OnFishingLureCleared")
end


function uespLog.OnFishingLureSet(eventCode, lureIndex)
	local name, texture, stack, sellPrice, quality = GetFishingLureInfo(lureIndex)

	uespLog.DebugExtraMsg("UESP: OnFishingLureSet "..tostring(lureIndex)..", "..tostring(name))
end


function uespLog.OnFishingReelInReady(eventCode, itemLink, itemName, bagId, slotIndex)
	uespLog.DebugExtraMsg("UESP: OnFishingReelInReady "..tostring(itemLink).."")

	if (not uespLog.GetFishingFlag()) then
		return
	end
	
	local count = GetItemTotalCount(bagId, slotIndex)
	local msg
	
	if (bagId == BAG_VIRTUAL) then
		local icon
		icon, count = GetItemInfo(bagId, slotIndex)
	end
	
	if (count == 0) then
		msg = "no more "..tostring(itemLink).." left"
	else
		msg = "x"..tostring(count).." "..tostring(itemLink).." left"
	end
	
	uespLog.MsgColor(uespLog.fishingColor, "Fish is ready to reel in NOW..."..msg.."!")
end


function uespLog.DumpChampionPoints2(note)
	local numDisc = GetNumChampionDisciplines()
	local logData = {}
	
	uespLog.Msg("Dumping all champion point data to log...")
	logData.event = "CP2::start"
	logData.note = note
	uespLog.AppendDataToLog("all", logData, uespLog.GetTimeData())
	
	for disciplineIndex = 1, numDisc do
		uespLog.DumpChampionPointDiscipine2(disciplineIndex)
	end
	
	logData = {}
	logData.event = "CP2::end"
	uespLog.AppendDataToLog("all", logData)
end


function uespLog.DumpChampionPointDiscipine2(disciplineIndex)
	local logData = {}
	
	logData.event = "CP2::disc"
	logData.discIndex = disciplineIndex
	logData.discId = GetChampionDisciplineId(disciplineIndex)
	logData.name = GetChampionDisciplineName(logData.discId)
	logData.type = GetChampionDisciplineType(logData.discId)
	logData.bgTexture = GetChampionDisciplineBackgroundTexture(logData.discId)
	logData.glowTexture = GetChampionDisciplineBackgroundGlowTexture(logData.discId)
	logData.selTexture = GetChampionDisciplineBackgroundSelectedTexture(logData.discId)
	logData.numSkills = GetNumChampionDisciplineSkills(disciplineIndex)	
	
	uespLog.AppendDataToLog("all", logData)
	
	for skillIndex = 1, logData.numSkills do
		uespLog.DumpChampionPointSkill2(disciplineIndex, skillIndex)
	end
end


function uespLog.DumpChampionPointSkill2(disciplineIndex, skillIndex)
	local logData = {}
	
	logData.event = "CP2"
	logData.discIndex = disciplineIndex
	logData.discId = GetChampionDisciplineId(disciplineIndex)
	logData.skillIndex = skillIndex
	logData.skillId = GetChampionSkillId(disciplineIndex, skillIndex)
	logData.x, logData.y = GetChampionSkillPosition(logData.skillId)
	logData.name = GetChampionSkillName(logData.skillId)
	logData.skillType = GetChampionSkillType(logData.skillId)
	
	local linkedIds = { GetChampionSkillLinkIds(logData.skillId) }
	
	if (linkedIds ~= nil) then
		logData.linkedIds = uespLog.implode(linkedIds, ",")
	end
	
	if (DoesChampionSkillHaveJumpPoints(logData.skillId)) then
		local jumpPoints = { GetChampionSkillJumpPoints(logData.skillId) }
		logData.jumpPoints = uespLog.implode(jumpPoints, ",")
	end	
		
	logData.isRoot = IsChampionSkillRootNode(logData.skillId)
	logData.isClusterRoot = IsChampionSkillClusterRoot(logData.skillId)
	
	if (logData.isClusterRoot) then
		logData.clusterName = GetChampionClusterName(logData.skillId)
		logData.clusterTexture = GetChampionClusterBackgroundTexture(logData.skillId)
		local skillIds = { GetChampionClusterSkillIds(logData.skillId) }
		logData.clusterSkills = uespLog.implode(skillIds, ",")
	end
	
	--logData.unlockLevel = GetChampionSkillUnlockLevel(disciplineIndex, skillIndex)
	--logData.isUnlocked = WouldChampionSkillNodeBeUnlocked(*integer* _championSkillId_, *integer* _pendingPoints_)
	logData.maxPoints = GetChampionSkillMaxPoints(logData.skillId)
	logData.abilityId = GetChampionAbilityId(logData.skillId)
	
	local minBonus = GetChampionSkillCurrentBonusText(logData.skillId, 0)
	local maxBonus = GetChampionSkillCurrentBonusText(logData.skillId, logData.maxPoints)
	local minDesc = GetChampionSkillDescription(logData.skillId, 0)
	local maxDesc = GetChampionSkillDescription(logData.skillId, logData.maxPoints)
	
	minDesc = minDesc:gsub("\n\nCurrent bonus: |cffffff0|r%%", "")
	maxDesc = maxDesc:gsub("\n\nCurrent bonus: |cffffff0|r%%", "")
	minDesc = minDesc:gsub("\n\nCurrent value: |cffffff0|r%%", "")
	maxDesc = maxDesc:gsub("\n\nCurrent value: |cffffff0|r%%", "")
	minDesc = minDesc:gsub("\n\nCurrent bonus: |cffffff0|r", "")
	maxDesc = maxDesc:gsub("\n\nCurrent bonus: |cffffff0|r", "")
	minDesc = minDesc:gsub("\n\nCurrent value: |cffffff0|r", "")
	maxDesc = maxDesc:gsub("\n\nCurrent value: |cffffff0|r", "")
	
	if (maxBonus ~= "") then
		logData.desc = minDesc .. "\nCurrent bonus: " .. minBonus
		logData.maxDesc = maxDesc .. "\nCurrent bonus: " .. maxBonus
	else
		logData.desc = minDesc
		logData.maxDesc = maxDesc
	end
	
	uespLog.AppendDataToLog("all", logData)
	
	local maxPoints = logData.maxPoints
	local skillId = logData.skillId
	local abilityId = logData.abilityId
	
	for i = 0, maxPoints do
		local bonus = GetChampionSkillCurrentBonusText(skillId, i)
		
		logData = {}
		logData.event = "CP2::desc"
		logData.skillId = skillId
		logData.abilityId = abilityId
		logData.points = i
		
		local desc = GetChampionSkillDescription(skillId, i)
		desc = desc:gsub("\n\nCurrent bonus: |cffffff0|r%%", "")
		desc = desc:gsub("\n\nCurrent bonus: |cffffff0|r", "")
		desc = desc:gsub("\n\nCurrent value: |cffffff0|r%%", "")
		desc = desc:gsub("\n\nCurrent value: |cffffff0|r", "")
		
		if (bonus ~= "") then
			logData.desc = desc .. "\nCurrent bonus: " .. bonus
		else
			logData.desc = desc
		end
		
		uespLog.AppendDataToLog("all", logData)
	end	

end


function uespLog.DumpChampionPoints(note)
	local numDisc = GetNumChampionDisciplines()
	local logData = {}
	
	uespLog.Msg("Dumping all champion point data to log...")
	
	logData.event = "CP::start"
	logData.note = note
	logData.maxPoints = GetMaxPossiblePointsInChampionSkill()
	uespLog.AppendDataToLog("all", logData, uespLog.GetTimeData())
	
	for disciplineIndex = 1, numDisc do
		uespLog.DumpChampionPointDiscipine(disciplineIndex)
	end
	
	logData = {}
	logData.event = "CP::end"
	uespLog.AppendDataToLog("all", logData)
end


function uespLog.DumpChampionPointDiscipine(disciplineIndex)
	local logData = {}
	
	logData.event = "CP::disc"
	logData.discIndex = disciplineIndex
	logData.name = GetChampionDisciplineName(disciplineIndex)
	logData.desc = GetChampionDisciplineDescription(disciplineIndex)	
	logData.attr = GetChampionDisciplineAttribute(disciplineIndex)	
	logData.numSkills = GetNumChampionDisciplineSkills(disciplineIndex)	
	
	uespLog.AppendDataToLog("all", logData)
	
	for skillIndex = 1, logData.numSkills do
		uespLog.DumpChampionPointSkill(disciplineIndex, skillIndex)
	end
	
end


function uespLog.DumpChampionPointSkill(disciplineIndex, skillIndex)
	local maxPoints = GetMaxPossiblePointsInChampionSkill()
	local logData = {}
	
	if (GetChampionAbilityDescription == nil) then
		return
	end
	
	logData.event = "CP"
	logData.discIndex = disciplineIndex
	logData.skillIndex = skillIndex
	logData.x, logData.y = GetChampionSkillPosition(disciplineIndex, skillIndex)
	logData.name = GetChampionSkillName(disciplineIndex, skillIndex)
	logData.unlockLevel = GetChampionSkillUnlockLevel(disciplineIndex, skillIndex)
	logData.abilityId = GetChampionAbilityId(disciplineIndex, skillIndex)
	logData.desc = GetChampionAbilityDescription(logData.abilityId, 0)
	logData.maxDesc = GetChampionAbilityDescription(logData.abilityId, maxPoints)
	
	uespLog.AppendDataToLog("all", logData)
	
	if (logData.unlockLevel ~= nil) then
		return
	end
	
	local abilityId = logData.abilityId
	
	for i = 0, maxPoints do
		logData = {}
		logData.event = "CP::desc"
		logData.abilityId = abilityId
		logData.points = i
		logData.desc = GetChampionAbilityDescription(abilityId, i)
		
		uespLog.AppendDataToLog("all", logData)
	end	

end


function uespLog.DoShowCoorCommand(cmd)
	local cmds, firstCmd = uespLog.SplitCommands(cmd)
	
	if (firstCmd == "on") then
		uespLog.SetShowCursorMapCoordsFlag(true)
		uespLog.Msg("Show map coordinates is now ON.")
	elseif (firstCmd == "off") then
		uespLog.SetShowCursorMapCoordsFlag(false)
		uespLog.Msg("Show map coordinates is now OFF.")
	else
		uespLog.Msg("Turn the map coordinates display on/off:")
		uespLog.Msg(".    /uespshowcoor [on/off]")
		uespLog.Msg("Map coordinate display is currently "..uespLog.BoolToOnOff(uespLog.GetShowCursorMapCoordsFlag())..".")
	end
	
end


SLASH_COMMANDS["/uespshowcoor"] = uespLog.DoShowCoorCommand


function uespLog.DoTrackStatCommand(cmd)
	local cmds, firstCmd = uespLog.SplitCommands(cmd)
	local secondCmd = string.lower(cmds[2])
	local secondCmdBool = nil
	local setPowerType = nil
	
	if (secondCmd == "on") then
		secondCmdBool = true
	elseif (secondCmd == "off") then
		secondCmdBool = false
	end
	
	if (firstCmd == "all") then
		uespLog.SetTrackStat(POWERTYPE_MAGICKA, true)
		uespLog.SetTrackStat(POWERTYPE_STAMINA, true)
		uespLog.SetTrackStat(POWERTYPE_HEALTH, true)
		uespLog.SetTrackStat(POWERTYPE_ULTIMATE, true)
		uespLog.SetTrackStat("Spell Damage", true)
		uespLog.SetTrackStat("Weapon Damage", true)
		uespLog.Msg("Now tracking all stats.")
	elseif (firstCmd == "none") then
		uespLog.SetTrackStat(POWERTYPE_MAGICKA, false)
		uespLog.SetTrackStat(POWERTYPE_STAMINA, false)
		uespLog.SetTrackStat(POWERTYPE_HEALTH, false)
		uespLog.SetTrackStat(POWERTYPE_ULTIMATE, false)
		uespLog.SetTrackStat("Spell Damage", false)
		uespLog.SetTrackStat("Weapon Damage", false)
		uespLog.Msg("Now tracking no stats.")
	elseif (firstCmd == "magicka") then
		setPowerType = POWERTYPE_MAGICKA
	elseif (firstCmd == "stamina") then
		setPowerType = POWERTYPE_STAMINA
	elseif (firstCmd == "health") then
		setPowerType = POWERTYPE_HEALTH
	elseif (firstCmd == "ultimate") then
		setPowerType = POWERTYPE_ULTIMATE
	elseif (firstCmd == "spelldamage" or firstCmd == "sd") then
		setPowerType = "Spell Damage"
	elseif (firstCmd == "weapondamage" or firstCmd == "wd") then
		setPowerType = "Weapon Damage"
	elseif (firstCmd == "resettime") then
		uespLog.baseTrackStatGameTime = GetGameTimeMilliseconds()
		uespLog.Msg("Game time for stat tracking reset to 0.")
	else
		local trackMag = uespLog.GetTrackStat(POWERTYPE_MAGICKA)
		local trackSta = uespLog.GetTrackStat(POWERTYPE_STAMINA)
		local trackHea = uespLog.GetTrackStat(POWERTYPE_HEALTH)
		local trackUlt = uespLog.GetTrackStat(POWERTYPE_ULTIMATE)
		
		uespLog.Msg("Permits tracking of changes to health/magicka/stmaina/ultimate:")
		uespLog.Msg(".    /uesptrackstat health     [on/off]    - Currently "..uespLog.BoolToOnOff(trackHea))
		uespLog.Msg(".    /uesptrackstat magicka  [on/off]    - Currently "..uespLog.BoolToOnOff(trackMag))
		uespLog.Msg(".    /uesptrackstat stamina   [on/off]    - Currently "..uespLog.BoolToOnOff(trackSta))
		uespLog.Msg(".    /uesptrackstat ultimate   [on/off]    - Currently "..uespLog.BoolToOnOff(trackUlt))
		uespLog.Msg(".    /uesptrackstat all                          - Track all stats")
		uespLog.Msg(".    /uesptrackstat none                       - Track no stats")
		uespLog.Msg(".    /uesptrackstat resettime                - Reset display game time to 0")
	end
	
	if (setPowerType ~= nil) then
	
		if (secondCmd == nil or secondCmd == "") then
			secondCmdBool = not uespLog.GetTrackStat(setPowerType)
			uespLog.SetTrackStat(setPowerType, secondCmdBool)
			uespLog.Msg("Set "..firstCmd.." stat tracking to "..uespLog.BoolToOnOff(secondCmdBool)..".")
		elseif (secondCmdBool == nil) then
			uespLog.Msg("Unknown option to /uesptrackstat. Should be 'on' or 'off'!")
		else
			uespLog.SetTrackStat(setPowerType, secondCmdBool)
			uespLog.Msg("Set "..firstCmd.." stat tracking to "..uespLog.BoolToOnOff(secondCmdBool)..".")
		end
	end
	
end


SLASH_COMMANDS["/uesptrackstat"] = uespLog.DoTrackStatCommand

--[[==== 
GetNumMaps()
Returns: number numMaps
GetMapInfo(number index)
Returns: string name, number UIMapType mapType, number MapContentType mapContentType, number zoneId
GetZoneDescription(number zoneId)
Returns: string description
GetZoneId(number zoneIndex)
Returns: number zoneId
GetZoneIndex(number zoneId)
Returns: number zoneIndex
--====]]

--[[==== 
GetNumPOIs(number zoneIndex)
Returns: number numPOIs
GetPOIInfo(number zoneIndex, number poiIndex)
Returns: string objectiveName, number objectiveLevel, string startDescription, string finishedDescription
IsPOIWayshrine(number zoneIndex, number poiIndex)
Returns: boolean isWayshrine
IsPOIPublicDungeon(number zoneIndex, number poiIndex)
Returns: boolean isPublicDungeon
IsPOIGroupDungeon(number zoneIndex, number poiIndex)
Returns: boolean isGroupDungeon
GetPOIMapInfo(number zoneIndex, number poiIndex)
Returns: number normalizedX, number normalizedZ, number MapDisplayPinType poiType, textureName icon, boolean isShownInCurrentMap, boolean linkedCollectibleIsLocked
GetCurrentSubZonePOIIndices()
Returns: number:nilable zoneIndex, number:nilable poiIndex
GetCollectibleIdForZone(number zoneIndex)
Returns: number collectibleId
IsJusticeEnabledForZone(number aZoneIndex)
Returns: boolean isBountyEnabled
GetZoneNameByIndex(number zoneIndex)
Returns: string zoneName
GetMapNameByIndex(number mapIndex)
Returns: string mapName
--====]]

--[[==== 
GetAchievementRewardCollectible(number achievementId)
Returns: boolean hasRewardOfType, number collectibleId
--====]]


function uespLog.MineCollectibleCategories(note)
	local numCategories = GetNumCollectibleCategories()
	local logData = {}
	local totalCount = 0
	
	uespLog.Msg("Logging all collectible categories...")
	
	logData.event = "MineCollect::Start"
	logData.numCategories = numCategories
	logData.note = note
	uespLog.AppendDataToLog("all", logData, uespLog.GetTimeData())
	
	for categoryIndex = 1, numCategories do
		local name, numSubCategories, numCollectibles, unlockedCollectibles, totalCollectibles, hidesLocked = GetCollectibleCategoryInfo(categoryIndex)
		local normalIcon, pressedIcon, mouseoverIcon = GetCollectibleCategoryKeyboardIcons(categoryIndex)
		local gamepadIcon = GetCollectibleCategoryGamepadIcon(categoryIndex)
		
		logData = {}
		logData.event = "MineCollect::Category"
		logData.name = name
		logData.categoryIndex = categoryIndex
		logData.numSubCategories = numSubCategories
		logData.numCollectibles = numCollectibles
		logData.totalCollectibles = totalCollectibles
		logData.hidesLocked = hidesLocked
		logData.normalIcon = normalIcon
		logData.pressedIcon = pressedIcon
		logData.mouseoverIcon = mouseoverIcon
		logData.gamepadIcon = gamepadIcon
		uespLog.AppendDataToLog("all", logData)
		
		for subCategoryIndex = 1, numSubCategories do
			local name, numCollectibles, unlockedCollectibles, totalCollectibles = GetCollectibleSubCategoryInfo(categoryIndex, subCategoryIndex)
			
			logData = {}
			logData.event = "MineCollect::Subcategory"
			logData.name = name
			logData.subCategoryIndex = subCategoryIndex
			logData.numCollectibles = numCollectibles
			logData.totalCollectibles = totalCollectibles
			uespLog.AppendDataToLog("all", logData)
			
			for collectibleIndex = 1, numCollectibles do
				local collectibleId = GetCollectibleId(categoryIndex, subCategoryIndex, collectibleIndex)
				
				logData = {}
				logData.event = "MineCollect::Index"
				logData.categoryIndex = categoryIndex
				logData.subCategoryIndex = subCategoryIndex
				logData.collectibleIndex = collectibleIndex
				logData.collectibleId = collectibleId
				uespLog.AppendDataToLog("all", logData)
				
				totalCount = totalCount + 1
			end
		end

	end
	
	logData = {}
	logData.event = "MineCollect::End"
	uespLog.AppendDataToLog("all", logData)
	
	uespLog.Msg("Found "..tostring(totalCount).." collectible categories!")
end


function uespLog.MineCollectibleIDs(note)
	local logData = {}
	local totalCount = 0
	local zoneCollectionIds = {}
	local achievementCollectionIds = {}
	local zoneCount = 0
	local achieveCount = 0
	
	uespLog.Msg("Logging all valid collectible IDs...")
	
	for zoneIndex = 1, 10000 do
		local collectibleId = GetCollectibleIdForZone(zoneIndex)
		
		if (collectibleId > 0) then
			zoneCollectionIds[collectibleId] = zoneIndex
			zoneCount = zoneCount + 1
		end
	end
	
	uespLog.Msg("Found "..zoneCount.." zones with collectibles!")
	
	for achieveIndex = 1, 10000 do
		local _, collectibleId = GetAchievementRewardCollectible(achieveIndex)
		
		if (collectibleId > 0) then
			achievementCollectionIds[collectibleId] = achieveIndex
			achieveCount = achieveCount + 1
		end
	end
	
	uespLog.Msg("Found "..achieveCount.." achievements with collectibles!")
	
	logData.event = "MineCollectID::Start"
	logData.numCategories = numCategories
	logData.note = note
	uespLog.AppendDataToLog("all", logData, uespLog.GetTimeData())
	
	for collectibleId = 1, 50000 do
		local name, description, icon, lockedIcon, unlocked, purchasable, isActive, categoryType, hint, isPlaceholder = GetCollectibleInfo(collectibleId)
		
		if (name ~= nil and name ~= "") then
			logData = {}
			logData.event = "MineCollectID"
			logData.id = collectibleId
			logData.name = name
			logData.description = description
			logData.icon = icon
			logData.lockedIcon = lockedIcon
			logData.unlocked = unlocked
			logData.isActive = isActive
			logData.categoryType = categoryType
			logData.hint = hint
			logData.isPlaceholder = isPlaceholder
			logData.zoneIndex = zoneCollectionIds[collectibleId]
			logData.achieveIndex = achievementCollectionIds[collectibleId]
			
			logData.bgImage = GetCollectibleKeyboardBackgroundImage(collectibleId)
			logData.gamepadBgImage = GetCollectibleGamepadBackgroundImage(collectibleId)
			logData.category, logData.subCategory, logData.index = GetCategoryInfoFromCollectibleId(collectibleId)
			
			logData.categoryName = GetCollectibleCategoryInfo(logData.category)
			logData.subCategoryName = GetCollectibleSubCategoryInfo(logData.category, logData.subCategory)
			
			logData.isSlottable = IsCollectibleSlottable(collectibleId)
			logData.isUsable = IsCollectibleUsable(collectibleId)
			logData.isRenameable = IsCollectibleRenameable(collectibleId)
			
			if (IsCollectiblePlaceholder) then
				logData.isPlaceholder = IsCollectiblePlaceholder(collectibleId)
			else
				logData.isPlaceholder = false
			end
			logData.itemLink = GetCollectibleLink(collectibleId)
			
			logData.nickname = GetCollectibleNickname(collectibleId)
			logData.helpCategoryIndex, logData.helpIndex = GetCollectibleHelpIndices(collectibleId)
			
			logData.questName, logData.backgroundText = GetCollectibleQuestPreviewInfo(collectibleId)
			_, logData.cooldown = GetCollectibleCooldownAndDuration(collectibleId)
			logData.isHidden, logData.visualPriority = WouldCollectibleBeHidden(collectibleId)
			logData.hasAppearance = DoesCollectibleHaveVisibleAppearance(collectibleId)
			
			logData.furnId = GetCollectibleFurnitureDataId(collectibleId)
			
			if (logData.furnId) then
				logData.furnCateId, logData.furnSubcateId, logData.furnTheme = GetFurnitureDataInfo(logData.furnId)
				logData.furnCateName = GetFurnitureCategoryName(logData.furnCateId)
				logData.furnSubcateName = GetFurnitureCategoryName(logData.furnSubcateId)
			end

			uespLog.AppendDataToLog("all", logData)
			
			totalCount = totalCount + 1
		end
	end
	
	
	logData = {}
	logData.event = "MineCollectID::End"
	uespLog.AppendDataToLog("all", logData)
	
	uespLog.Msg("Found and logged "..tostring(totalCount).." collectibles!")
end


function uespLog.MineCollectCommand(cmd)
	local cmds, firstCmd = uespLog.SplitCommands(cmd)
	uespLog.MineCollectibleIDs(firstCmd)
end


SLASH_COMMANDS["/uespminecollect"] = uespLog.MineCollectCommand


function uespLog.ContainerLootCommand(cmd)
	local cmds, firstCmd = uespLog.SplitCommands(cmd)
	
	if (firstCmd == "on") then
		uespLog.SetContainerAutoLoot(true)
		uespLog.Msg("Turned container auto-looting on.")
	elseif (firstCmd == "off") then
		uespLog.SetContainerAutoLoot(false)
		uespLog.Msg("Turned container auto-looting off.")
	else
		uespLog.Msg("Command Format: /uespcontloot [on||off]")
		uespLog.Msg("Container auto-looting is "..uespLog.BoolToOnOff(uespLog.GetContainerAutoLoot()))
	end
	
end


SLASH_COMMANDS["/uespcontloot"] = uespLog.ContainerLootCommand


function uespLog.CustomStatsCommand(cmd)
	local cmds, firstCmd = uespLog.SplitCommands(cmd)
	
	if (firstCmd == "on") then
		uespLog.SetCustomStatDisplay(true)
		uespLog.Msg("Turned custom stat display on (reload UI to take effect)")
		
		if (uespLog.GetInventoryStatsConfig() == "off") then
			uespLog.SetInventoryStatsConfig("on")
			uespLog.ModifyInventoryStatsWindow()
		end
		
	elseif (firstCmd == "off") then
		uespLog.SetCustomStatDisplay(false)
		uespLog.Msg("Turned custom stat display off (reload UI to take effect)")
		
		if (uespLog.GetInventoryStatsConfig() ~= "off") then
			uespLog.SetInventoryStatsConfig("off")
			--uespLog.ModifyInventoryStatsWindow()
		end
		
	elseif (firstCmd == "custom") then
		uespLog.SetCustomStatDisplay(true)
		uespLog.Msg("Turned custom stat display to custom (reload UI to take effect)")
		
		if (uespLog.GetInventoryStatsConfig() ~= "custom") then
			uespLog.SetInventoryStatsConfig("custom")
			uespLog.ModifyInventoryStatsWindow()
		end
	else
		uespLog.Msg("Command Format: /uespcustomstats [on||off||custom]")
		uespLog.Msg("Changes to this setting require you to reload the UI to take effect.")
		
		if (uespLog.GetInventoryStatsConfig() == "custom") then
			uespLog.Msg("Custom stat display is on (custom)")
		else
			uespLog.Msg("Custom stat display is "..uespLog.BoolToOnOff(uespLog.GetCustomStatDisplay()))
		end
	end
	
end


SLASH_COMMANDS["/uespcustomstats"] = uespLog.CustomStatsCommand
SLASH_COMMANDS["/uespcustomstat"] = uespLog.CustomStatsCommand


uespLog.STAT_EFFECTIVE_SPELL_POWER = -100
uespLog.STAT_EFFECTIVE_WEAPON_POWER = -101
uespLog.STAT_SPELL_CRITICAL_DAMAGE = -102
uespLog.STAT_WEAPON_CRITICAL_DAMAGE = -103
uespLog.EFFECTIVE_SPELL_POWER_TEXT = "Eff Spell Power"
uespLog.EFFECTIVE_WEAPON_POWER_TEXT = "Eff Weapon Power"
uespLog.SPELL_CRITICAL_DAMAGE_TEXT = "Spell Crit Dmg"
uespLog.WEAPON_CRITICAL_DAMAGE_TEXT = "Weapon Crit Dmg"


function uespLog.GetActiveWeaponTypes()
	local activeIndex = GetActiveWeaponPairInfo()
	local weaponType1 = 0
	local weaponType2 = 0
	
	if (activeIndex == 1) then
		weaponType1 = GetItemWeaponType(BAG_WORN, EQUIP_SLOT_MAIN_HAND)
		weaponType2 = GetItemWeaponType(BAG_WORN, EQUIP_SLOT_OFF_HAND)
	else
		weaponType1 = GetItemWeaponType(BAG_WORN, EQUIP_SLOT_BACKUP_MAIN)
		weaponType2 = GetItemWeaponType(BAG_WORN, EQUIP_SLOT_BACKUP_OFF)
	end
	
	return weaponType1, weaponType2
end


function uespLog.GetAttackSpellMitigation()
	local AttackMitigation  = 0
	local PenetrationFactor = 0
	local Penetration = GetPlayerStat(STAT_SPELL_PENETRATION, STAT_BONUS_OPTION_APPLY_BONUS, STAT_SOFT_CAP_OPTION_APPLY_SOFT_CAP)
	local Level = GetUnitLevel("player")
	local EffectiveLevel = GetUnitEffectiveLevel("player")
	local TargetDefenseBonus = 0
	local currentRank = GetSkillAbilityUpgradeInfo(2, 5, 8)		-- 5/10%
	local weaponType1, weaponType2 = uespLog.GetActiveWeaponTypes()
	
		-- Destruction Staff: Penetrating Magic Passive
	if (weaponType1 == WEAPONTYPE_FIRE_STAFF or weaponType1 == WEAPONTYPE_FROST_STAFF or weaponType1 == WEAPONTYPE_LIGHTNING_STAFF) then
		if (currentRank == 1) then
			PenetrationFactor = 0.05 
		elseif (currentRank == 2) then
			PenetrationFactor = 0.10 
		end
	end
	
	-- AttackMitigation = (((Target.SpellResist)*(1 - Skill2.SpellPenetration) - SpellPenetration)*(-1/(Level * 1000)) + 1)*(1 - Target.DefenseBonus)
	AttackMitigation = uespLog.savedVars.settings.data.targetResistance * (1 - PenetrationFactor)
	AttackMitigation = AttackMitigation - Penetration
	AttackMitigation = 1 + AttackMitigation * (-1 / (EffectiveLevel * 1000))
	AttackMitigation = AttackMitigation * (1 - TargetDefenseBonus)
	
	if (AttackMitigation > 1) then AttackMitigation = 1 end
	if (AttackMitigation < 0) then AttackMitigation = 0 end
	
	return AttackMitigation
end


function uespLog.GetAttackPhysicalMitigation()
	local AttackMitigation  = 0
	local PenetrationFactor = 0
	local Penetration = GetPlayerStat(STAT_PHYSICAL_PENETRATION, STAT_BONUS_OPTION_APPLY_BONUS, STAT_SOFT_CAP_OPTION_APPLY_SOFT_CAP)
	local Level = GetUnitLevel("player")
	local EffectiveLevel = GetUnitEffectiveLevel("player")
	local TargetDefenseBonus = 0
	local currentRank2H = GetSkillAbilityUpgradeInfo(2, 1, 8)		-- 10/20%
	local currentRankDW = GetSkillAbilityUpgradeInfo(2, 3, 11)		-- 5/10% x1/2
	local activeWeaponType = 1
	local weaponType1, weaponType2 = uespLog.GetActiveWeaponTypes()
	
		-- 2H Passive
	if (weaponType1 == WEAPONTYPE_TWO_HANDED_HAMMER) then
		if (currentRank2H == 1) then
			PenetrationFactor = 0.10 
		elseif (currentRank2H == 2) then
			PenetrationFactor = 0.20 
		end
		
		-- 1H Passive
	elseif (weaponType1 == WEAPONTYPE_HAMMER or weaponType2 == WEAPONTYPE_HAMMER) then
		
		if (currentRankDW == 1) then
			PenetrationFactor = 0.05 
		elseif (currentRankDW == 2) then
			PenetrationFactor = 0.10 
		end
		
		if (weaponType1 == WEAPONTYPE_HAMMER and weaponType2 == WEAPONTYPE_HAMMER) then
			PenetrationFactor = PenetrationFactor * 2
		end
	end
	
	-- AttackMitigation = (((Target.PhysicalResist)*(1 - Skill2.PhysicalPenetration) - PhysicalPenetration)*(-1/(Level * 1000)) + 1)*(1 - Target.DefenseBonus)
	AttackMitigation = uespLog.savedVars.settings.data.targetResistance * (1 - PenetrationFactor)
	AttackMitigation = AttackMitigation - Penetration
	AttackMitigation = 1 + AttackMitigation * (-1 / (EffectiveLevel * 1000))
	AttackMitigation = AttackMitigation * (1 - TargetDefenseBonus)
	
	if (AttackMitigation > 1) then AttackMitigation = 1 end
	if (AttackMitigation < 0) then AttackMitigation = 0 end
	
	return AttackMitigation
end


function uespLog.GetPlayerMundus()
	local mundus1 = ""
	local mundus2 = ""
	local numBuffs = GetNumBuffs("player")
	
	for i = 1, numBuffs do
		local buffName = GetUnitBuffInfo("player", i)
		local mundusName = buffName:match("Boon: (.*)")
		
		if (mundusName ~= nil) then
		
			if (mundus1 == "") then
				mundus1 = mundusName
			else
				mundus2 = mundusName
			end
		end
	end
	
	return mundus1, mundus2
end


function uespLog.GetPlayerDivineEffect()
	local wornItems = GetBagSize(BAG_WORN)
	local totalDivines = 0
	
	for i = 0, wornItems do
		local itemLink = GetItemLink(BAG_WORN, i)
		local traitType, traitDesc = GetItemLinkTraitInfo(itemLink)
		
		if (traitType == ITEM_TRAIT_TYPE_ARMOR_DIVINES) then
			local value = traitDesc:match(" by |c[a-fA-F0-9][a-fA-F0-9][a-fA-F0-9][a-fA-F0-9][a-fA-F0-9][a-fA-F0-9]([%d\.]+)|r%%")
			
			if (value ~= nil) then
				totalDivines = totalDivines + tonumber(value)/100
			end
		end
	end
	
	return totalDivines
end


function uespLog.FindPlayerSkillLineName(skillLineName)
	local numSkillTypes = GetNumSkillTypes()

	for skillType = 1, numSkillTypes do
		local numSkillLines = GetNumSkillLines(skillType)
		
		for skillLine = 1, numSkillLines do
			local name = GetSkillLineInfo(skillType, skillLine)
			
			if (name == skillLineName) then
				return skillType, skillLine
			end
		end
	end

	return -1, -1
end


function uespLog.DoesPlayerHaveSkillLineSlotted(skillLine)
	local skillType, skillLine = uespLog.FindPlayerSkillLineName(skillLine)
		
	if (skillType < 0) then
		return false
	end
	
	local skillIds = {}
	local numAbilities = GetNumSkillAbilities(skillType, skillLine)
	
	for i = 3, 8 do
		local id = GetSlotBoundId(i)
		skillIds[id] = true
	end
	
	for i = 1, numAbilities do
		local id = GetSkillAbilityId(skillType, skillLine, i)
		
		if (skillIds[id] ~= nil) then
			return true
		end
	end

	return false
end


function uespLog.CountItemLinkSetItemsWorn(itemLink)
	local hasSet, setName, numBonuses, numEquipped, maxEquipped = GetItemLinkSetInfo(itemLink, false)
	return numEquipped
end


function uespLog.GetPlayerBaseCriticalDamage()
	local critDamage = 0.50
	local majorForce = 0
	local mundus1, mundus2 = uespLog.GetPlayerMundus()
	
		-- Templar:Piercing Spear 31698/44046, 5/10%
	local currentId = GetSkillAbilityId(1, 1, 7)
	
	if (uespLog.DoesPlayerHaveSkillLineSlotted("Aedric Spear")) then
		if (currentId == 31698) then
			critDamage = critDamage + 0.05
		elseif (currentId == 44046) then
			critDamage = critDamage + 0.10		
		end
	end
	
		-- Nightblade: Assassination, 36641/45060, 5/10%
	currentId = GetSkillAbilityId(1, 1, 10)
	
	if (uespLog.DoesPlayerHaveSkillLineSlotted("Assassination")) then
		if (currentId == 36641) then
			critDamage = critDamage + 0.05
		elseif (currentId == 45060) then
			critDamage = critDamage + 0.10		
		end
	end
	
		-- Sets: Archer's Mind
	if (uespLog.CountItemLinkSetItemsWorn("|H0:item:43761:6:33:0:0:0:0:0:0:0:0:0:0:0:0:8:0:0:0:0:0|h|h") >= 5) then
		critDamage = critDamage + 0.05
		
		if (GetUnitStealthState("Player")) then
			critDamage = critDamage + 0.10
		end
	end
		
		-- Buffs: Minor Force=12%, Major Force=30%
	local numBuffs = GetNumBuffs("player")
	
	for i = 1, numBuffs do
		local buffName, timeStarted, timeEnded = GetUnitBuffInfo("player", i)
		
		if (buffName == "Minor Force") then
			critDamage = critDamage + 0.12
		elseif (buffName == "Major Force") then
			majorForce = 0.30
		elseif (buffName == "Aggressive Horn") then		-- Doesn't seem to have its own seperate buff for Major Force
			local currentTime = GetGameTimeMilliseconds()/1000
			local deltaTime = currentTime - timeStarted
			
			if (deltaTime <= 9.5) then
				majorForce = 0.30
			end
		end
	end
		
		-- Mundus: The Shadow * Divines
	if (mundus1 == "The Shadow" or mundus2 == "The Shadow") then
		local Divines = uespLog.GetPlayerDivineEffect()
		critDamage = critDamage + 0.12 * (1 + Divines)
	end
	
	return critDamage * (1 + majorForce)
end


function uespLog.IsCp2SkillEquipped(findSkillId)

	if (GetAssignableChampionBarStartAndEndSlots == nil) then
		return false
	end
	
	local startSlotIndex, endSlotIndex = GetAssignableChampionBarStartAndEndSlots()
	local slotIndex
	local slotData = {}
	
	for slotIndex = startSlotIndex, endSlotIndex do
		local skillId = GetSlotBoundId(slotIndex, HOTBAR_CATEGORY_CHAMPION)
		
		if (skillId == findSkillId) then
			return true
		end
	end
	
	return false
end


function uespLog.GetPlayerSpellCriticalDamage()

	local critDamage = uespLog.GetPlayerBaseCriticalDamage()
		
		-- The Apprentice:Elfborn 61680	7	3
	local numPoints = GetNumPointsSpentOnChampionSkill(7, 3)
	
	if (numPoints ~= nil and numPoints > 0 and GetChampionAbilityDescription ~= nil) then
		local abilityId = GetChampionAbilityId(7, 3)
		local description = GetChampionAbilityDescription(abilityId, 0)
		local value = description:match(" by |c[a-fA-F0-9][a-fA-F0-9][a-fA-F0-9][a-fA-F0-9][a-fA-F0-9][a-fA-F0-9]([%d.]+)|r%%")
		
		if (value ~= nil) then
			critDamage = critDamage + tonumber(value)/100
		end
	end
	
		-- 141899 Fighting Finesse
	if (uespLog.IsCp2SkillEquipped(12)) then
		local spentPoints = GetNumPointsSpentOnChampionSkill(12)
		local description = GetChampionSkillDescription(12, spentPoints)
		local bonusText = GetChampionSkillCurrentBonusText(12, spentPoints)
		local value = description:match(" |c[a-fA-F0-9][a-fA-F0-9][a-fA-F0-9][a-fA-F0-9][a-fA-F0-9][a-fA-F0-9]([%d.]+)|r%%")
		
		if (value ~= nil) then
			critDamage = critDamage + tonumber(value)/100
		end
	end
	
		-- 142006 Backstabber
	if (uespLog.IsCp2SkillEquipped(31)) then
		local spentPoints = GetNumPointsSpentOnChampionSkill(31)
		local description = GetChampionSkillDescription(31, spentPoints)
		local bonusText = GetChampionSkillCurrentBonusText(31, spentPoints)
		local value = description:match(" |c[a-fA-F0-9][a-fA-F0-9][a-fA-F0-9][a-fA-F0-9][a-fA-F0-9][a-fA-F0-9]([%d.]+)|r%%")
		
		if (value ~= nil) then
			critDamage = critDamage + tonumber(value)/100
		end
	end
	
	return math.floor(critDamage*1000 + 0.5)/1000
end


function uespLog.GetPlayerWeaponCriticalDamage()
	
	local critDamage = uespLog.GetPlayerBaseCriticalDamage()
		
		--The Ritual:Precise Strikes 59105	5	2
	local numPoints = GetNumPointsSpentOnChampionSkill(5, 2)
	
	if (numPoints ~= nil and numPoints > 0 and GetChampionAbilityDescription ~= nil) then
		local abilityId = GetChampionAbilityId(5, 2)
		local description = GetChampionAbilityDescription(abilityId, 0)
		local value = description:match(" by |c[a-fA-F0-9][a-fA-F0-9][a-fA-F0-9][a-fA-F0-9][a-fA-F0-9][a-fA-F0-9]([%d.]+)|r%%")
		
		if (value ~= nil) then
			critDamage = critDamage + tonumber(value)/100
		end
		
	end	
	
		-- 141899 Fighting Finesse
	if (uespLog.IsCp2SkillEquipped(12)) then
		local spentPoints = GetNumPointsSpentOnChampionSkill(12)
		local description = GetChampionSkillDescription(12, spentPoints)
		local bonusText = GetChampionSkillCurrentBonusText(12, spentPoints)
		local value = description:match(" |c[a-fA-F0-9][a-fA-F0-9][a-fA-F0-9][a-fA-F0-9][a-fA-F0-9][a-fA-F0-9]([%d.]+)|r%%")
		
		if (value ~= nil) then
			critDamage = critDamage + tonumber(value)/100
		end
	end
	
		-- 142006 Backstabber
	if (uespLog.IsCp2SkillEquipped(31)) then
		local spentPoints = GetNumPointsSpentOnChampionSkill(31)
		local description = GetChampionSkillDescription(31, spentPoints)
		local bonusText = GetChampionSkillCurrentBonusText(31, spentPoints)
		local value = description:match(" |c[a-fA-F0-9][a-fA-F0-9][a-fA-F0-9][a-fA-F0-9][a-fA-F0-9][a-fA-F0-9]([%d.]+)|r%%")
		
		if (value ~= nil) then
			critDamage = critDamage + tonumber(value)/100
		end
	end
	
	return math.floor(critDamage*1000 + 0.5)/1000
end


function uespLog.GetEffectiveSpellPower()
	local Magicka = GetPlayerStat(STAT_MAGICKA_MAX, STAT_BONUS_OPTION_APPLY_BONUS, STAT_SOFT_CAP_OPTION_APPLY_SOFT_CAP)
	local SpellDamage = GetPlayerStat(STAT_SPELL_POWER, STAT_BONUS_OPTION_APPLY_BONUS, STAT_SOFT_CAP_OPTION_APPLY_SOFT_CAP)
	local SpellCrit = GetPlayerStat(STAT_SPELL_CRITICAL, STAT_BONUS_OPTION_APPLY_BONUS, STAT_SOFT_CAP_OPTION_APPLY_SOFT_CAP)
	local SpellCritDamage = uespLog.GetPlayerSpellCriticalDamage()
	local AttackSpellMitigation = uespLog.GetAttackSpellMitigation()
	local Level = GetUnitLevel("player")
	local EffectiveLevel = GetUnitEffectiveLevel("player")
	local TargetCritResistFactor = uespLog.savedVars.settings.data.targetCritResistFactor
	local TargetCritResistFlat = uespLog.savedVars.settings.data.targetCritResistFlat
	local AttackCrit = SpellCrit - TargetCritResistFactor - (TargetCritResistFlat)*(0.035/250)
	local MagicDamageDone = uespLog.GetMagicDamageDone()
	local DamageDone = uespLog.GetDamageDone()
	local result = 0
	
	SpellCrit = math.floor(AttackCrit / (2 * EffectiveLevel * (100 + EffectiveLevel)) * 1000 + 0.5)/1000
	
		-- EffectiveSpellPower = (round(Magicka/10.5) + SpellDamage)*(1 + AttackSpellCrit*SpellCritDamage)*(AttackSpellMitigation)
	result = math.floor(Magicka/10.5 + 0.5) + SpellDamage
	result = result * (1 + SpellCrit * SpellCritDamage)
	result = result * AttackSpellMitigation
	result = result * (1 + MagicDamageDone)
	result = result * (1 + DamageDone)
		
	result = math.floor(result)
	
		-- Prevent rare nan value result from unknown circumstances
	if (result ~= result) then
		result = 0
	end
	
	return result
end


function uespLog.GetMagicDamageDone()

	local result = 0

	if (GetChampionAbilityDescription ~= nil) then
		local description = GetChampionAbilityDescription(63848, 0)
		local value = description:match(" by |c[a-fA-F0-9][a-fA-F0-9][a-fA-F0-9][a-fA-F0-9][a-fA-F0-9][a-fA-F0-9]([%d.]+)|r%%")
		
		if (value ~= nil) then
			result = result + tonumber(value)/100
		end
	end
	
	return result
end


function uespLog.GetStaminaDamageDone()

	local result = 0

	if (GetChampionAbilityDescription ~= nil) then	
		local description = GetChampionAbilityDescription(63868, 0)
		local value = description:match(" by |c[a-fA-F0-9][a-fA-F0-9][a-fA-F0-9][a-fA-F0-9][a-fA-F0-9][a-fA-F0-9]([%d.]+)|r%%")
		
		if (value ~= nil) then
			result = result + tonumber(value)/100
		end
	end
	
	return result
end


function uespLog.GetDamageDone()
	local result = 0
	local twinBladePassiveRank = GetSkillAbilityUpgradeInfo(2, 3, 11)
	local heavyWeaponPassiveRank = GetSkillAbilityUpgradeInfo(2, 1, 8)
	local numSwords = uespLog.CountEquippedWeapons(WEAPONTYPE_SWORD)
	local num2HSwords = uespLog.CountEquippedWeapons(WEAPONTYPE_TWO_HANDED_SWORD)
	
		-- DW Twin Blade and Blunt (30893/45482) 2-3-11
	if (twinBladePassiveRank == 1) then
		result = result + 0.015 * numSwords
	elseif (twinBladePassiveRank == 2) then
		result = result + 0.025 * numSwords
	end
	
		-- 2H Heavy Weapon
	if (heavyWeaponPassiveRank == 1) then
		result = result + 0.03 * num2HSwords
	elseif (heavyWeaponPassiveRank == 1) then
		result = result + 0.05 * num2HSwords
	end
	
		-- TODO: Stealthed
		
		-- TODO: Warden Animal Companions
		
		-- TODO: Essence Thief
	
		-- TODO: Buffs
	local numBuffs = GetNumBuffs("player")
	
	for i = 1, numBuffs do
		local buffName = GetUnitBuffInfo("player", i)
		
		if (buffName == "Minor Slayer") then
			result = result + 0.05
		elseif (buffName == "Major Slayer") then
			result = result + 0.15
		elseif (buffName == "Major Berserk") then
			result = result + 0.25
		elseif (buffName == "Minor Berserk") then
			result = result + 0.08
		elseif (buffName == "Major Maim") then
			result = result - 0.30
		elseif (buffName == "Minor Maim") then
			result = result - 0.15
		elseif (buffName == "Yokudan Might") then
			result = result + 0.08
		end
	end

	return result
end


function uespLog.GetEffectiveWeaponPower()
	local Stamina = GetPlayerStat(STAT_STAMINA_MAX, STAT_BONUS_OPTION_APPLY_BONUS, STAT_SOFT_CAP_OPTION_APPLY_SOFT_CAP)
	local WeaponDamage = GetPlayerStat(STAT_POWER, STAT_BONUS_OPTION_APPLY_BONUS, STAT_SOFT_CAP_OPTION_APPLY_SOFT_CAP)
	local WeaponCrit = GetPlayerStat(STAT_CRITICAL_STRIKE, STAT_BONUS_OPTION_APPLY_BONUS, STAT_SOFT_CAP_OPTION_APPLY_SOFT_CAP)
	local WeaponCritDamage = uespLog.GetPlayerWeaponCriticalDamage()
	local AttackPhysicalMitigation = uespLog.GetAttackPhysicalMitigation()
	local Level = GetUnitLevel("player")
	local EffectiveLevel = GetUnitEffectiveLevel("player")
	local TargetCritResistFactor = uespLog.savedVars.settings.data.targetCritResistFactor
	local TargetCritResistFlat = uespLog.savedVars.settings.data.targetCritResistFlat
	local AttackCrit = WeaponCrit - TargetCritResistFactor - (TargetCritResistFlat)*(0.035/250)
	local StaminaDamageDone = uespLog.GetStaminaDamageDone()
	local DamageDone = uespLog.GetDamageDone()
	local result = 0
	
	WeaponCrit = math.floor(AttackCrit / (2 * EffectiveLevel * (100 + EffectiveLevel)) * 1000 + 0.5)/1000
	
		--EffectiveWeaponPower = (round(Stamina/10.5) + WeaponDamage)*(1 + AttackWeaponCrit*WeaponCritDamage)*(AttackPhysicalMitigation)
	result = math.floor(Stamina/10.5 + 0.5) + WeaponDamage
	result = result * (1 + WeaponCrit * WeaponCritDamage)
	result = result * AttackPhysicalMitigation
	result = result * (1 + StaminaDamageDone)
	result = result * (1 + DamageDone)
	
	result = math.floor(result)
	
		-- Prevent rare nan value result from unknown circumstances
	if (result ~= result) then
		result = 0
	end
	
	return result
end


function uespLog:ZO_StatEntry_Keyboard_GetValue()

	if (self.statType == uespLog.STAT_EFFECTIVE_SPELL_POWER) then
		return uespLog.GetEffectiveSpellPower()
	elseif (self.statType == uespLog.STAT_EFFECTIVE_WEAPON_POWER) then
		return uespLog.GetEffectiveWeaponPower()
	elseif (self.statType == uespLog.STAT_SPELL_CRITICAL_DAMAGE) then
		return tostring(math.floor(uespLog.GetPlayerSpellCriticalDamage()*100 + 0.5)) .. "%"
	elseif (self.statType == uespLog.STAT_WEAPON_CRITICAL_DAMAGE) then
		return tostring(math.floor(uespLog.GetPlayerWeaponCriticalDamage()*100 + 0.5)) .. "%"
	end

    return GetPlayerStat(self.statType, STAT_BONUS_OPTION_APPLY_BONUS, STAT_SOFT_CAP_OPTION_APPLY_SOFT_CAP)
end


function uespLog:CreateAttributesSection()
	
	uespLog.Old_ZO_Stats_CreateAttributesSection(self)
	
	if (not uespLog.GetCustomStatDisplay()) then
		return
	end
		
	self:SetNextControlPadding(20)
    self:AddStatRow(STAT_SPELL_PENETRATION, STAT_PHYSICAL_PENETRATION)
	self:SetNextControlPadding(0)
	self:AddStatRow(uespLog.STAT_SPELL_CRITICAL_DAMAGE, uespLog.STAT_WEAPON_CRITICAL_DAMAGE)
	self:SetNextControlPadding(0)
	self:AddStatRow(uespLog.STAT_EFFECTIVE_SPELL_POWER, uespLog.STAT_EFFECTIVE_WEAPON_POWER)
		
		-- A fix for SI_STAT_SPELL_PENETRATION being "Focus Rating" for some reason
	self.statEntries[STAT_SPELL_PENETRATION].control.name:SetText(uespLog.SPELL_PENETRATION_TEXT)
	
	self.statEntries[uespLog.STAT_EFFECTIVE_SPELL_POWER].control.name:SetText(uespLog.EFFECTIVE_SPELL_POWER_TEXT)
	self.statEntries[uespLog.STAT_EFFECTIVE_WEAPON_POWER].control.name:SetText(uespLog.EFFECTIVE_WEAPON_POWER_TEXT)
	self.statEntries[uespLog.STAT_SPELL_CRITICAL_DAMAGE].control.name:SetText(uespLog.SPELL_CRITICAL_DAMAGE_TEXT)
	self.statEntries[uespLog.STAT_WEAPON_CRITICAL_DAMAGE].control.name:SetText(uespLog.WEAPON_CRITICAL_DAMAGE_TEXT)
end


function uespLog.AddCharacterWindowStats()

	if (not uespLog.GetCustomStatDisplay()) then
		return
	end

	--table.insert(ZO_INVENTORY_STAT_GROUPS, { STAT_SPELL_PENETRATION, STAT_PHYSICAL_PENETRATION })
	--table.insert(ZO_INVENTORY_STAT_GROUPS, { uespLog.STAT_EFFECTIVE_SPELL_POWER, uespLog.STAT_EFFECTIVE_WEAPON_POWER })
	--table.insert(ZO_INVENTORY_STAT_GROUPS, { uespLog.STAT_SPELL_CRITICAL_DAMAGE, uespLog.STAT_WEAPON_CRITICAL_DAMAGE })
	
	uespLog.Old_ZO_Stats_CreateAttributesSection = ZO_Stats.CreateAttributesSection
	ZO_Stats.CreateAttributesSection = uespLog.CreateAttributesSection
	STATS.CreateAttributesSection = uespLog.CreateAttributesSection
	
	uespLog.Old_ZO_StatEntry_Keyboard_GetValue = ZO_StatEntry_Keyboard.GetValue
	ZO_StatEntry_Keyboard.GetValue = uespLog.ZO_StatEntry_Keyboard_GetValue
	
	local statsWindow = ZO_CharacterWindowStats
	
	if (statsWindow == nil) then
		return
	end
	
	local parentControl = statsWindow:GetNamedChild("ScrollScrollChild")
    local lastControl = ZO_CharacterWindowStatsScrollScrollChildStatEntry24
    local nextPaddingY = 25
	
	if (parentControl == nil or lastControl == nil) then
		return
	end
	
	local statControl = CreateControlFromVirtual("$(parent)StatEntryUesp", parentControl, "ZO_StatsEntry", STAT_SPELL_PENETRATION)
	local relativeAnchorSide = (lastControl == nil) and TOP or BOTTOM
	
	if (statControl == nil) then
		return
	end
	
	statControl:SetAnchor(TOP, lastControl, relativeAnchorSide, 0, nextPaddingY)
	local statEntry = ZO_StatEntry_Keyboard:New(statControl, STAT_SPELL_PENETRATION)
	statEntry.tooltipAnchorSide = LEFT
	statEntry.control.name:SetText(" "..uespLog.SPELL_PENETRATION_TEXT)
	lastControl = statControl
	nextPaddingY = 5
	
	statControl = CreateControlFromVirtual("$(parent)StatEntryUesp", parentControl, "ZO_StatsEntry", STAT_PHYSICAL_PENETRATION)
	relativeAnchorSide = (lastControl == nil) and TOP or BOTTOM
	statControl:SetAnchor(TOP, lastControl, relativeAnchorSide, 0, nextPaddingY)
	statEntry = ZO_StatEntry_Keyboard:New(statControl, STAT_PHYSICAL_PENETRATION)
	statEntry.tooltipAnchorSide = LEFT
	statEntry.control.name:SetText(" "..uespLog.PHYSICAL_PENETRATION_TEXT)
	lastControl = statControl
	nextPaddingY = 25
	
	statControl = CreateControlFromVirtual("$(parent)StatEntryUesp", parentControl, "ZO_StatsEntry", uespLog.STAT_SPELL_CRITICAL_DAMAGE)
	relativeAnchorSide = (lastControl == nil) and TOP or BOTTOM
	statControl:SetAnchor(TOP, lastControl, relativeAnchorSide, 0, nextPaddingY)
	statEntry = ZO_StatEntry_Keyboard:New(statControl, uespLog.STAT_SPELL_CRITICAL_DAMAGE)
	statEntry.tooltipAnchorSide = LEFT
	statEntry.control.name:SetText(" "..uespLog.SPELL_CRITICAL_DAMAGE_TEXT)
	lastControl = statControl
	nextPaddingY = 5
	
	statControl = CreateControlFromVirtual("$(parent)StatEntryUesp", parentControl, "ZO_StatsEntry", uespLog.STAT_WEAPON_CRITICAL_DAMAGE)
	relativeAnchorSide = (lastControl == nil) and TOP or BOTTOM
	statControl:SetAnchor(TOP, lastControl, relativeAnchorSide, 0, nextPaddingY)
	statEntry = ZO_StatEntry_Keyboard:New(statControl, uespLog.STAT_WEAPON_CRITICAL_DAMAGE)
	statEntry.tooltipAnchorSide = LEFT
	statEntry.control.name:SetText(" "..uespLog.WEAPON_CRITICAL_DAMAGE_TEXT)
	lastControl = statControl
	nextPaddingY = 25
	
	statControl = CreateControlFromVirtual("$(parent)StatEntryUesp", parentControl, "ZO_StatsEntry", uespLog.STAT_EFFECTIVE_SPELL_POWER)
	relativeAnchorSide = (lastControl == nil) and TOP or BOTTOM
	statControl:SetAnchor(TOP, lastControl, relativeAnchorSide, 0, nextPaddingY)
	statEntry = ZO_StatEntry_Keyboard:New(statControl, uespLog.STAT_EFFECTIVE_SPELL_POWER)
	statEntry.tooltipAnchorSide = LEFT
	statEntry.control.name:SetText(" "..uespLog.EFFECTIVE_SPELL_POWER_TEXT)
	lastControl = statControl
	nextPaddingY = 5
	
	statControl = CreateControlFromVirtual("$(parent)StatEntryUesp", parentControl, "ZO_StatsEntry", uespLog.STAT_EFFECTIVE_WEAPON_POWER)
	relativeAnchorSide = (lastControl == nil) and TOP or BOTTOM
	statControl:SetAnchor(TOP, lastControl, relativeAnchorSide, 0, nextPaddingY)
	statEntry = ZO_StatEntry_Keyboard:New(statControl, uespLog.STAT_EFFECTIVE_WEAPON_POWER)
	statEntry.tooltipAnchorSide = LEFT
	statEntry.control.name:SetText(" "..uespLog.EFFECTIVE_WEAPON_POWER_TEXT)
	lastControl = statControl
	nextPaddingY = 25
		
end


function uespLog.ShowMessageStatus()
	local lootMsg = uespLog.BoolToOnOff(uespLog.GetMessageDisplay(uespLog.MSG_LOOT))
	local npcMsg = uespLog.BoolToOnOff(uespLog.GetMessageDisplay(uespLog.MSG_NPC))
	local questMsg = uespLog.BoolToOnOff(uespLog.GetMessageDisplay(uespLog.MSG_QUEST))
	local xpMsg = uespLog.BoolToOnOff(uespLog.GetMessageDisplay(uespLog.MSG_XP))
	local miscMsg = uespLog.BoolToOnOff(uespLog.GetMessageDisplay(uespLog.MSG_MISC))
	local inspirationMsg = uespLog.BoolToOnOff(uespLog.GetMessageDisplay(uespLog.MSG_INSPIRATION))
	
	uespLog.Msg("Loot messages are "..lootMsg)
	uespLog.Msg("NPC messages are "..npcMsg)
	uespLog.Msg("Quest messages are "..questMsg)
	uespLog.Msg("Experience messages are "..xpMsg)
	uespLog.Msg("Inspiration messages are "..inspirationMsg)
	uespLog.Msg("Other messages are "..miscMsg)
end


function uespLog.MessageCommand(cmds)
	local cmds, firstCmd = uespLog.SplitCommands(cmds)
	local secondCmd = string.lower(cmds[2] or "")
	
	if (firstCmd == "other") then
		firstCmd = "misc"
	end
	
	if (secondCmd == "on") then
		secondCmd = true
	elseif (secondCmd == "off") then
		secondCmd = false
	else
		secondCmd = uespLog.GetMessageDisplay(firstCmd)
	end
	
	if (firstCmd == "on") then
		uespLog.SetMessageDisplay(uespLog.MSG_LOOT, true)
		uespLog.SetMessageDisplay(uespLog.MSG_NPC, true)
		uespLog.SetMessageDisplay(uespLog.MSG_XP, true)
		uespLog.SetMessageDisplay(uespLog.MSG_QUEST, true)
		uespLog.SetMessageDisplay(uespLog.MSG_MISC, true)
		uespLog.SetMessageDisplay(uespLog.MSG_INSPIRATION, true)
		uespLog.ShowMessageStatus()
	elseif (firstCmd == "off") then
		uespLog.SetMessageDisplay(uespLog.MSG_LOOT, false)
		uespLog.SetMessageDisplay(uespLog.MSG_NPC, false)
		uespLog.SetMessageDisplay(uespLog.MSG_QUEST, false)
		uespLog.SetMessageDisplay(uespLog.MSG_XP, false)
		uespLog.SetMessageDisplay(uespLog.MSG_MISC, false)
		uespLog.SetMessageDisplay(uespLog.MSG_INSPIRATION, false)
		uespLog.ShowMessageStatus()
	elseif (firstCmd == "inspiration") then
		uespLog.SetMessageDisplay(uespLog.MSG_INSPIRATION, secondCmd)
		uespLog.Msg("Display of inspiration messages is "..uespLog.BoolToOnOff(secondCmd))
	elseif (firstCmd == "npc") then
		uespLog.SetMessageDisplay(uespLog.MSG_NPC, secondCmd)
		uespLog.Msg("Display of NPC messages is "..uespLog.BoolToOnOff(secondCmd))
	elseif (firstCmd == "xp") then
		uespLog.SetMessageDisplay(uespLog.MSG_XP, secondCmd)
		uespLog.Msg("Display of experience messages is "..uespLog.BoolToOnOff(secondCmd))
	elseif (firstCmd == "loot") then
		uespLog.SetMessageDisplay(uespLog.MSG_LOOT, secondCmd)
		uespLog.Msg("Display of loot messages is "..uespLog.BoolToOnOff(secondCmd))
	elseif (firstCmd == "quest") then
		uespLog.SetMessageDisplay(uespLog.MSG_QUEST, secondCmd)
		uespLog.Msg("Display of quest messages is "..uespLog.BoolToOnOff(secondCmd))
	elseif (firstCmd == "misc") then
		uespLog.SetMessageDisplay(uespLog.MSG_MISC, secondCmd)
		uespLog.Msg("Display of other messages is "..uespLog.BoolToOnOff(secondCmd))
	else
		uespLog.Msg("Turns specific uespLog chat messages on/off. Command format is:")
		uespLog.Msg(".    /uespmsg [on||off]                 Turns all messages on/off")
		uespLog.Msg(".    /uespmsg loot [on||off]          Turns loot messages on/off")
		uespLog.Msg(".    /uespmsg npc [on||off]          Turns npc messages on/off")
		uespLog.Msg(".    /uespmsg xp [on||off]           Turns experience messages on/off")
		uespLog.Msg(".    /uespmsg quest [on||off]       Turns quest messages on/off")
		uespLog.Msg(".    /uespmsg inspiration [on||off]  Turns inspiration messages on/off")
		uespLog.Msg(".    /uespmsg other [on||off]        Turns other messages on/off")
		uespLog.ShowMessageStatus()
	end
	
end


SLASH_COMMANDS["/uespmsg"] = uespLog.MessageCommand


function uespLog.ShowBuffsCommand(cmds)
	local numBuffs = GetNumBuffs("player")
	
	uespLog.Msg("Listing all "..tostring(numBuffs).." buffs currently on player:")
	
	for i = 1, numBuffs do
		local buffName = GetUnitBuffInfo("player", i)
		
		uespLog.Msg(".     "..tostring(i)..") "..tostring(buffName).."")
	end
	
end


SLASH_COMMANDS["/uespshowbuffs"] = uespLog.ShowBuffsCommand


function uespLog.TrackLootCommand(cmds)
	local cmds, firstCmd = uespLog.SplitCommands(cmds)
	
	if (firstCmd == "on") then
		uespLog.SetTrackLoot(true)
		uespLog.savedVars.charInfo.data.trackedLoot.lastCheckGameTime = GetGameTimeMilliseconds()
		uespLog.Msg("Loot tracking is now on!")
	elseif (firstCmd == "off") then
		uespLog.UpdateTrackLootTime()
		uespLog.SetTrackLoot(false)
		uespLog.Msg("Loot tracking is now off!")
	elseif (firstCmd == "" or firstCmd == "show" or firstCmd == "items") then
		uespLog.UpdateTrackLootTime()
		uespLog.ShowTrackLoot(cmds[2])
	elseif (firstCmd == "sources" or firstCmd == "src") then
		uespLog.UpdateTrackLootTime()
		uespLog.ShowTrackLootSources(cmds[2])
	elseif (firstCmd == "reset") then
		uespLog.InitializeTrackLootData(true)
		uespLog.Msg("Reset loot tracking data!")
	else
		uespLog.Msg("Turns the tracking of loot on/off and displays tracked loot stats. This command does not alter what data is logged.")
		uespLog.Msg(".     /uesptrackloot help                      Show command details")
		uespLog.Msg(".     /uesptrackloot [on||off]                 Turns loot tracking on/off")
		uespLog.Msg(".     /uesptrackloot                       Displays all items looted")
		uespLog.Msg(".     /uesptrackloot show                   Displays all items looted")
		uespLog.Msg(".     /uesptrackloot show [name]       Displays any matching loot items")
		uespLog.Msg(".     /uesptrackloot sources               Displays all loot sources")
		uespLog.Msg(".     /uesptrackloot sources [name]   Displays any matching loot sources")
		uespLog.Msg(".     /uesptrackloot reset                    Reset all tracked loot stats")
		uespLog.Msg("Loot tracking is currently "..uespLog.BoolToOnOff(uespLog.GetTrackLoot()))
	end
	
end


SLASH_COMMANDS["/uesptrackloot"] = uespLog.TrackLootCommand


function uespLog.InitializeTrackLootData(forceInit)
	
	if (uespLog.savedVars.charInfo.data.trackedLoot == nil) then
		uespLog.savedVars.charInfo.data.trackedLoot = {}
	end
	
	if (forceInit or uespLog.savedVars.charInfo.data.trackedLoot.items == nil) then
		uespLog.savedVars.charInfo.data.trackedLoot.items = {}
	end
	
	if (forceInit or uespLog.savedVars.charInfo.data.trackedLoot.sources == nil) then
		uespLog.savedVars.charInfo.data.trackedLoot.sources = {}
	end
	
	if (forceInit or uespLog.savedVars.charInfo.data.trackedLoot.secondsPassed == nil) then
		uespLog.savedVars.charInfo.data.trackedLoot.secondsPassed = 0
	end
	
	uespLog.savedVars.charInfo.data.trackedLoot.lastCheckGameTime = GetGameTimeMilliseconds()
end


function uespLog.UpdateTrackLootTime()

	if (not uespLog.GetTrackLoot()) then
		return false
	end
	
	local currentGameTime = GetGameTimeMilliseconds()
	local deltaTime = (currentGameTime - uespLog.savedVars.charInfo.data.trackedLoot.lastCheckGameTime) / 1000
	
	uespLog.savedVars.charInfo.data.trackedLoot.secondsPassed = uespLog.savedVars.charInfo.data.trackedLoot.secondsPassed + deltaTime
	
	uespLog.savedVars.charInfo.data.trackedLoot.lastCheckGameTime = currentGameTime
end



function uespLog.TrackLoot(itemLink, qnt, source)
	--uespLog.savedVars.charInfo.data.trackedLoot

	if (not uespLog.GetTrackLoot()) then
		return false
	end
	
	qnt = qnt or 1
	if (qnt == 0) then qnt = 1 end
	source = source or ""
		
	if (uespLog.savedVars.charInfo.data.trackedLoot.items[itemLink] == nil) then
		uespLog.savedVars.charInfo.data.trackedLoot.items[itemLink] = 0
	end
	
	uespLog.savedVars.charInfo.data.trackedLoot.items[itemLink] = uespLog.savedVars.charInfo.data.trackedLoot.items[itemLink] + qnt
	
	if (source ~= nil) then
		uespLog.TrackLootSource(source)
	else
		uespLog.UpdateTrackLootTime()
	end
	return true
end


uespLog.lastTrackLootSource = ""
uespLog.lastTrackLootSourceGameTime = 0


function uespLog.TrackLootSource(source)
	local gameTime = GetGameTimeMilliseconds()
	local gameTimeDelta = gameTime - uespLog.lastTrackLootSourceGameTime

	if (source == nil or source == "") then
		source = "unknown"
	end
	
	if (uespLog.savedVars.charInfo.data.trackedLoot.sources[source] == nil) then
		uespLog.savedVars.charInfo.data.trackedLoot.sources[source] = 0
	end
	
	if (uespLog.lastTrackLootSource == source and gameTimeDelta <= 99) then
		return false
	end
		
	uespLog.savedVars.charInfo.data.trackedLoot.sources[source] = uespLog.savedVars.charInfo.data.trackedLoot.sources[source] + 1
	
	uespLog.lastTrackLootSource = source
	uespLog.lastTrackLootSourceGameTime = gameTime
		
	uespLog.UpdateTrackLootTime()
	return true
end


function uespLog.GetMMItemLinkValue(itemLink)

	if (MasterMerchant == nil) then
		return 0
	end
	
	local mmData = MasterMerchant:itemStats(itemLink, false)
	
	if (mmData == nil or mmData.avgPrice == nil) then
		return 0
	end
	
	return mmData.avgPrice
end


function uespLog.GetItemLinkValue(itemLink)
	local mmPrice = uespLog.GetMMItemLinkValue(itemLink)
	local uespPrice = uespLog.FindSalesPrice(itemLink)
	
	if (uespPrice ~= nil and uespPrice.price > 0) then
		return uespPrice.price, "uesp"
	end
	
	if (mmPrice > 0) then
		return mmPrice, "mm"
	end
	
	return GetItemLinkValue(itemLink), "default"
end



uespLog.TRACK_LOOT_TEMPER_BLACKSMITHING = 
{
	["|H0:item:54170:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"] = 0.0147,
	["|H0:item:54171:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"] = 0.0126,
	["|H0:item:54172:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"] = 0.0078,
	["|H0:item:54173:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"] = 0.0054,
}


uespLog.TRACK_LOOT_TEMPER_CLOTHING = 
{
	["|H0:item:54174:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"] = 0.0147,
	["|H0:item:54175:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"] = 0.0126,
	["|H0:item:54176:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"] = 0.0078,
	["|H0:item:54177:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"] = 0.0054,
}


uespLog.TRACK_LOOT_TEMPER_WOODWORKING = 
{
	["|H0:item:54178:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"] = 0.0147,
	["|H0:item:54179:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"] = 0.0126,
	["|H0:item:54180:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"] = 0.0078,
	["|H0:item:54181:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"] = 0.0054,
}


uespLog.REFINE_RAW_MATERIAL_CHANCE = 0.85


uespLog.TRACK_LOOT_TRANSFORM = 
{
	["rubedo hide scraps"] = 	-- |H0:item:71239:30:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h
		{
			["items"] = { ["|H0:item:64506:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"] = uespLog.REFINE_RAW_MATERIAL_CHANCE },
			["tempers"] = uespLog.TRACK_LOOT_TEMPER_CLOTHING,
			["itemLink"] = "|H0:item:71239:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
		},
	["shadowhide scraps"] = 	-- |H0:item:4478:30:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h
		{
			["items"] = { ["|H0:item:46138:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"] = uespLog.REFINE_RAW_MATERIAL_CHANCE },
			["tempers"] = uespLog.TRACK_LOOT_TEMPER_CLOTHING,
			["itemLink"] = "|H0:item:4478:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
		},	
	["superb hide scraps"] =
		{
			["items"] = { ["|H0:item:46137:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"] = uespLog.REFINE_RAW_MATERIAL_CHANCE },
			["tempers"] = uespLog.TRACK_LOOT_TEMPER_CLOTHING,
			["itemLink"] = "|H0:item:800:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
		},	
	["thick leather scraps"] =
		{
			["items"] = { ["|H0:item:23100:30:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"] = uespLog.REFINE_RAW_MATERIAL_CHANCE },
			["tempers"] = uespLog.TRACK_LOOT_TEMPER_CLOTHING,
			["itemLink"] = "|H0:item:6020:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
		},	
	["fell hide scraps"] =
		{
			["items"] = { ["|H0:item:23101:30:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"] = uespLog.REFINE_RAW_MATERIAL_CHANCE },
			["tempers"] = uespLog.TRACK_LOOT_TEMPER_CLOTHING,
			["itemLink"] = "|H0:item:23097:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
		},	
	["topgrain hide scraps"] =
		{
			["items"] = { ["|H0:item:46135:30:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"] = uespLog.REFINE_RAW_MATERIAL_CHANCE },
			["tempers"] = uespLog.TRACK_LOOT_TEMPER_CLOTHING,
			["itemLink"] = "|H0:item:23142:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
		},	
	["leather scraps"] =
		{
			["items"] = { ["|H0:item:23099:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"] = uespLog.REFINE_RAW_MATERIAL_CHANCE },
			["tempers"] = uespLog.TRACK_LOOT_TEMPER_CLOTHING,
			["itemLink"] = "|H0:item:23095:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
		},	
	["iron hide scraps"] =
		{
			["items"] = { ["|H0:item:46136:30:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"] = uespLog.REFINE_RAW_MATERIAL_CHANCE },
			["tempers"] = uespLog.TRACK_LOOT_TEMPER_CLOTHING,
			["itemLink"] = "|H0:item:23143:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
		},	
	["hide scraps"] =
		{
			["items"] = { ["|H0:item:4447:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"] = uespLog.REFINE_RAW_MATERIAL_CHANCE },
			["tempers"] = uespLog.TRACK_LOOT_TEMPER_CLOTHING,
			["itemLink"] = "|H0:item:4448:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
		},	
	["rawhide scraps"] =
		{
			["items"] = { ["|H0:item:794:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"] = uespLog.REFINE_RAW_MATERIAL_CHANCE },
			["tempers"] = uespLog.TRACK_LOOT_TEMPER_CLOTHING,
			["itemLink"] = "|H0:item:793:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
		},	
	
	["raw ancestor silk"] = 	-- |H0:item:71200:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h
		{
			["items"] = { ["|H0:item:64504:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"] = uespLog.REFINE_RAW_MATERIAL_CHANCE },
			["tempers"] = uespLog.TRACK_LOOT_TEMPER_CLOTHING,
			["itemLink"] = "|H0:item:71200:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
		},
	["raw void bloom"] =
		{
			["items"] = { ["|H0:item:46134:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"] = uespLog.REFINE_RAW_MATERIAL_CHANCE },
			["tempers"] = uespLog.TRACK_LOOT_TEMPER_CLOTHING,
			["itemLink"] = "|H0:item:33220:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
		},
	["raw spidersilk"] =
		{
			["items"] = { ["|H0:item:23126:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"] = uespLog.REFINE_RAW_MATERIAL_CHANCE },
			["tempers"] = uespLog.TRACK_LOOT_TEMPER_CLOTHING,
			["itemLink"] = "|H0:item:23130:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
		},
	["raw flax"] =
		{
			["items"] = { ["|H0:item:4463:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"] = uespLog.REFINE_RAW_MATERIAL_CHANCE },
			["tempers"] = uespLog.TRACK_LOOT_TEMPER_CLOTHING,
			["itemLink"] = "|H0:item:4464:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
		},
	["raw ebonthread"] =
		{
			["items"] = { ["|H0:item:23127:30:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"] = uespLog.REFINE_RAW_MATERIAL_CHANCE },
			["tempers"] = uespLog.TRACK_LOOT_TEMPER_CLOTHING,
			["itemLink"] = "|H0:item:23131:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
		},
	["raw silverweed"] =
		{
			["items"] = { ["|H0:item:46133:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"] = uespLog.REFINE_RAW_MATERIAL_CHANCE },
			["tempers"] = uespLog.TRACK_LOOT_TEMPER_CLOTHING,
			["itemLink"] = "|H0:item:33219:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
		},
	["raw ironweed"] =
		{
			["items"] = { ["|H0:item:46132:30:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"] = uespLog.REFINE_RAW_MATERIAL_CHANCE },
			["tempers"] = uespLog.TRACK_LOOT_TEMPER_CLOTHING,
			["itemLink"] = "|H0:item:33218:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
		},
	["raw kreshweed"] =
		{
			["items"] = { ["|H0:item:46131:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"] = uespLog.REFINE_RAW_MATERIAL_CHANCE },
			["tempers"] = uespLog.TRACK_LOOT_TEMPER_CLOTHING,
			["itemLink"] = "|H0:item:33217:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
		},
	["raw cotton"] =
		{
			["items"] = { ["|H0:item:23125:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"] = uespLog.REFINE_RAW_MATERIAL_CHANCE },
			["tempers"] = uespLog.TRACK_LOOT_TEMPER_CLOTHING,
			["itemLink"] = "|H0:item:23129:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
		},
	["raw jute"] =
		{
			["items"] = { ["|H0:item:811:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"] = uespLog.REFINE_RAW_MATERIAL_CHANCE },
			["tempers"] = uespLog.TRACK_LOOT_TEMPER_CLOTHING,
			["itemLink"] = "|H0:item:812:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
		},
	
	["rubedite ore"] = 		-- |H0:item:71198:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h
		{
			["items"] = { ["|H0:item:64489:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"] = uespLog.REFINE_RAW_MATERIAL_CHANCE },
			["tempers"] = uespLog.TRACK_LOOT_TEMPER_BLACKSMITHING,
			["itemLink"] = "|H0:item:71198:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
		},
	["voidstone ore"] =		-- |H0:item:23135:30:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h
		{
			["items"] = { ["|H0:item:46130:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"] = uespLog.REFINE_RAW_MATERIAL_CHANCE },
			["tempers"] = uespLog.TRACK_LOOT_TEMPER_BLACKSMITHING,
			["itemLink"] = "|H0:item:23135:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
		},
	["quicksilver ore"] =
		{
			["items"] = { ["|H0:item:46129:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"] = uespLog.REFINE_RAW_MATERIAL_CHANCE },
			["tempers"] = uespLog.TRACK_LOOT_TEMPER_BLACKSMITHING,
			["itemLink"] = "|H0:item:23134:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
		},
	["orichalcum ore"] =
		{
			["items"] = { ["|H0:item:23107:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"] = uespLog.REFINE_RAW_MATERIAL_CHANCE },
			["tempers"] = uespLog.TRACK_LOOT_TEMPER_BLACKSMITHING,
			["itemLink"] = "|H0:item:23103:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
		},
	["galatite ore"] =
		{
			["items"] = { ["|H0:item:46128:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"] = uespLog.REFINE_RAW_MATERIAL_CHANCE },
			["tempers"] = uespLog.TRACK_LOOT_TEMPER_BLACKSMITHING,
			["itemLink"] = "|H0:item:23133:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
		},
	["calcinium ore"] =
		{
			["items"] = { ["|H0:item:46127:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"] = uespLog.REFINE_RAW_MATERIAL_CHANCE },
			["tempers"] = uespLog.TRACK_LOOT_TEMPER_BLACKSMITHING,
			["itemLink"] = "|H0:item:4482:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
		},
	["ebony ore"] =
		{
			["items"] = { ["|H0:item:6001:30:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"] = uespLog.REFINE_RAW_MATERIAL_CHANCE },
			["tempers"] = uespLog.TRACK_LOOT_TEMPER_BLACKSMITHING,
			["itemLink"] = "|H0:item:23105:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
		},
	["dwarven ore"] =
		{
			["items"] = { ["|H0:item:6000:30:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"] = uespLog.REFINE_RAW_MATERIAL_CHANCE },
			["tempers"] = uespLog.TRACK_LOOT_TEMPER_BLACKSMITHING,
			["itemLink"] = "|H0:item:23104:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
		},
	["high iron ore"] =
		{
			["items"] = { ["|H0:item:4487:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"] = uespLog.REFINE_RAW_MATERIAL_CHANCE },
			["tempers"] = uespLog.TRACK_LOOT_TEMPER_BLACKSMITHING,
			["itemLink"] = "|H0:item:5820:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
		},
	["iron ore"] =
		{
			["items"] = { ["|H0:item:5413:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"] = uespLog.REFINE_RAW_MATERIAL_CHANCE },
			["tempers"] = uespLog.TRACK_LOOT_TEMPER_BLACKSMITHING,
			["itemLink"] = "|H0:item:808:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
		},
	
		
	["rough ruby ash"] = 	-- |H0:item:71199:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h
		{
			["items"] = { ["|H0:item:64502:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"] = uespLog.REFINE_RAW_MATERIAL_CHANCE },
			["tempers"] = uespLog.TRACK_LOOT_TEMPER_WOODWORKING,
			["itemLink"] = "|H0:item:71199:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
		},
	["rough nightwood"] = 	-- |H0:item:23138:30:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h
		{
			["items"] = { ["|H0:item:46142:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"] = uespLog.REFINE_RAW_MATERIAL_CHANCE },
			["tempers"] = uespLog.TRACK_LOOT_TEMPER_WOODWORKING,
			["itemLink"] = "|H0:item:23138:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
		},
	["rough ash"] = 
		{
			["items"] = { ["|H0:item:46140:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"] = uespLog.REFINE_RAW_MATERIAL_CHANCE },
			["tempers"] = uespLog.TRACK_LOOT_TEMPER_WOODWORKING,
			["itemLink"] = "|H0:item:4439:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
		},
	["rough beech"] = 
		{
			["items"] = { ["|H0:item:23121:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"] = uespLog.REFINE_RAW_MATERIAL_CHANCE },
			["tempers"] = uespLog.TRACK_LOOT_TEMPER_WOODWORKING,
			["itemLink"] = "|H0:item:23117:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
		},
	["rough birch"] = 
		{
			["items"] = { ["|H0:item:46139:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"] = uespLog.REFINE_RAW_MATERIAL_CHANCE },
			["tempers"] = uespLog.TRACK_LOOT_TEMPER_WOODWORKING,
			["itemLink"] = "|H0:item:818:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
		},
	["rough hickory"] = 
		{
			["items"] = { ["|H0:item:23122:30:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"] = uespLog.REFINE_RAW_MATERIAL_CHANCE },
			["tempers"] = uespLog.TRACK_LOOT_TEMPER_WOODWORKING,
			["itemLink"] = "|H0:item:23118:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
		},
	["rough mahogany"] = 
		{
			["items"] = { ["|H0:item:46141:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"] = uespLog.REFINE_RAW_MATERIAL_CHANCE },
			["tempers"] = uespLog.TRACK_LOOT_TEMPER_WOODWORKING,
			["itemLink"] = "|H0:item:23137:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
		},
	["rough maple"] = 
		{
			["items"] = { ["|H0:item:803:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"] = uespLog.REFINE_RAW_MATERIAL_CHANCE },
			["tempers"] = uespLog.TRACK_LOOT_TEMPER_WOODWORKING,
			["itemLink"] = "|H0:item:802:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
		},
	["rough oak"] = 
		{
			["items"] = { ["|H0:item:533:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"] = uespLog.REFINE_RAW_MATERIAL_CHANCE },
			["tempers"] = uespLog.TRACK_LOOT_TEMPER_WOODWORKING,
			["itemLink"] = "|H0:item:521:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
		},
	["rough yew"] = 
		{
			["items"] = { ["|H0:item:23123:30:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"] = uespLog.REFINE_RAW_MATERIAL_CHANCE },
			["tempers"] = uespLog.TRACK_LOOT_TEMPER_WOODWORKING,
			["itemLink"] = "|H0:item:23119:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
		},
	
}


function uespLog.GetTrackLootTransformValue(itemName, qnt, ignoreRefinedPrice)
	local transformData = nil
	local totalValue = 0
	
	if (ignoreRefinedPrice == nil) then 
		ignoreRefinedPrice = false 
	end
	
	if (itemName:sub(1, 1) == "|") then
		itemName = GetItemLinkName(itemName):gsub("%^.*", "")
	end
	
	itemName = itemName:lower()
	
	transformData = uespLog.TRACK_LOOT_TRANSFORM[itemName]
	
	if (transformData == nil) then
		return 0
	end
	
	if (not ignoreRefinedPrice) then
	
		for itemLink, chance in pairs(transformData.items) do
			local itemValue = GetItemLinkValue(itemLink)
			local itemMMValue = uespLog.GetItemLinkValue(itemLink)
			
			if (itemMMValue == 0) then
				totalValue = totalValue + itemValue * chance
			else
				totalValue = totalValue + itemMMValue * chance
			end
		end
	end
	
	for itemLink, chance in pairs(transformData.tempers) do
		local itemValue = GetItemLinkValue(itemLink)
		local itemMMValue = uespLog.GetItemLinkValue(itemLink)
		
		if (itemMMValue == 0) then
			totalValue = totalValue + itemValue * chance
		else
			totalValue = totalValue + itemMMValue * chance
		end
		
	end
	
	return totalValue * qnt
end


function uespLog.TrackLootItemNameKeySort(a, b)
	return a.name < b.name
end


function uespLog.ShowTrackLoot(itemMatch)
	local items = uespLog.savedVars.charInfo.data.trackedLoot.items
	local sources = uespLog.savedVars.charInfo.data.trackedLoot.sources
	local seconds = uespLog.savedVars.charInfo.data.trackedLoot.secondsPassed
	local i = 1
	local totalItems = 0
	local totalSources = 0
	local totalVendorValue = 0
	local totalMMValue = 0
	local totalValue = 0
	local itemNameKeys = {}
	
	if (itemMatch ~= nil) then
		itemMatch = itemMatch:lower()
		uespLog.Msg("Showing items matching '"..tostring(itemMatch).."'...")
	else
		uespLog.Msg("Showing all items current loot data...")
	end

	for itemLink in pairs(items) do
		table.insert(itemNameKeys, { name = GetItemLinkName(itemLink):lower(), ["itemLink"] = itemLink })
	end
	
	table.sort(itemNameKeys, uespLog.TrackLootItemNameKeySort)
	
	for _, itemData in pairs(itemNameKeys) do
		local itemName = itemData.name
		local itemLink = itemData.itemLink
		local qnt = items[itemLink]
		local isSpecial = false
		
		if (itemName == "") then
			itemName = itemLink:lower()
			isSpecial = true
		end
	
		if (itemMatch == nil or itemName:find(itemMatch) ~= nil) then
			local itemValue = 0
					
			if (isSpecial) then
				uespLog.Msg(".   "..tostring(i)..") "..tostring(qnt).." "..itemName)
				
				if (itemName == "gold") then
					totalVendorValue = totalVendorValue + qnt
					totalMMValue = totalMMValue + qnt
					totalValue = totalValue + qnt
					itemValue = qnt
				end
			else
				local itemVendorValue = GetItemLinkValue(itemLink) * qnt
				local itemMMValue = uespLog.GetItemLinkValue(itemLink) * qnt
				local transformValue = uespLog.GetTrackLootTransformValue(itemLink, qnt)
				
				if (transformValue ~= 0) then
					itemMMValue = transformValue
				end
				
				totalVendorValue = totalVendorValue + itemVendorValue
				totalMMValue = totalMMValue + itemMMValue
				
				if (itemMMValue == 0) then
					itemMMValue = "?"
					totalValue = totalValue + itemVendorValue
					itemValue = itemVendorValue
				else
					itemMMValue = string.format("%0.1f", itemMMValue)
					totalValue = totalValue + itemMMValue
					itemValue = itemMMValue
				end
				
				uespLog.Msg(".   "..tostring(i)..") "..tostring(itemLink).." x"..tostring(qnt).." (" .. tostring(itemValue).." gold)")
			end
			
			i = i + 1
		end	

		totalItems = totalItems + 1		
	end
	
	for source, qnt in pairs(sources) do
		totalSources = totalSources + 1
	end
		
	totalMMValue = math.floor(totalMMValue)
	totalValue = math.floor(totalValue)
	
	if (i == 1) then
		uespLog.Msg(".       No items found!")
	else
		uespLog.Msg(".       Total value of "..tostring(totalValue).." gold")
	end
	
	uespLog.Msg("You looted "..tostring(totalItems).." unique items from "..tostring(totalSources).." different sources over "..tostring(math.floor(seconds)).." seconds!")	
end


uespLog.CONTAINER_SOURCES = {
	["Apple Basket"] = 1,
	["Backpack"] = 1,
	["Bag"] = 1,
	["Barrel"] = 1,
	["Barrels"] = 1,
	["Basket"] = 1,
	["Burnt Barrel"] = 1,
	["Burnt Barrels"] = 1,
	["Burnt Crate"] = 1,
	["Burnt Crates"] = 1,
	["Corn Basket"] = 1,
	["Crate"] = 1,
	["Crates"] = 1,
	["Dresser"] = 1,
	["Dwemer Jug"] = 1,
	["Dwemer Pot"] = 1,
	["Flour Sack"] = 1,
	["Jug"] = 1,
	["Keg"] = 1,
	["Large Dwemer Jug"] = 1,
	["Large Dwemer Pot"] = 1,
	["Millet Sack"] = 1,
	["Nightstand"] = 1,
	["Sack"] = 1,
	["Saltrice Sack"] = 1,
	["Trunk"] = 1,
	["Tomb Urn"] = 1,
	["Urn"] = 1,
	["Wardrobe"] = 1,
}


function uespLog.ShowTrackLootSources(sourceMatch)
	local items = uespLog.savedVars.charInfo.data.trackedLoot.items
	local sources = uespLog.savedVars.charInfo.data.trackedLoot.sources
	local seconds = uespLog.savedVars.charInfo.data.trackedLoot.secondsPassed
	local i = 1
	local totalItems = 0
	local totalSources = 0
	local sourceNameKeys = {}
	local totalHeavySacks = sources["Heavy Sack"] or 0
	local totalChests = sources["Chest"] or 0
	local totalContainers = 0
	
	if (sourceMatch ~= nil) then
		sourceMatch = sourceMatch:lower()
		uespLog.Msg("Showing sources matching '"..tostring(sourceMatch).."'...")
	else
		uespLog.Msg("Showing all sources in current loot data...")
	end
	
	for source in pairs(sources) do
		table.insert(sourceNameKeys, source)
	end
	
	table.sort(sourceNameKeys)
	
	for _, source in pairs(sourceNameKeys) do
		local qnt = sources[source]
	
		if (sourceMatch == nil or source:lower():find(sourceMatch) ~= nil) then
			uespLog.Msg(".   "..tostring(i)..") "..tostring(source).." x"..tostring(qnt))
			i = i + 1
		end	
		
		if (uespLog.CONTAINER_SOURCES[source] ~= nil) then
			totalContainers = totalContainers + qnt
		end

		totalSources = totalSources + 1		
	end
	
	for itemLink, qnt in pairs(items) do
		totalItems = totalItems + 1
	end
	
	if (i == 1) then
		uespLog.Msg(".    No sources found!")
	end
	
	uespLog.Msg("You looted "..tostring(totalItems).." unique items from "..tostring(totalSources).." different sources over "..tostring(math.floor(seconds)).." seconds!")
	uespLog.Msg("You found "..tostring(totalChests).." chests, "..tostring(totalHeavySacks).." heavy sacks, and "..tostring(totalContainers).." containers.")
end


function uespLog.CompareRawPrices (materialMatch)
	local sellData = {}

	if (materialMatch == nil) then
		materialMatch = ""
		uespLog.Msg("Outputting prices for all raw materials:")
	elseif (materialMatch == "base") then
		uespLog.ShowBaseRawPrices()
		return
	else
		materialMatch = materialMatch:lower()
		uespLog.Msg("Outputting prices for all raw materials matching '"..materialMatch.."':")
	end
	
	for itemName, itemData in pairs(uespLog.TRACK_LOOT_TRANSFORM) do
		local itemLink = itemData.itemLink
		local itemName = GetItemLinkName(itemLink)
		
		if (materialMatch == "" or itemName:lower():find(materialMatch) ~= nil) then
			local transformValue = uespLog.GetTrackLootTransformValue(itemLink, 1)
			local itemMMValue = uespLog.GetItemLinkValue(itemLink)
			local profit = transformValue - itemMMValue
		
			table.insert(sellData, { itemLink = itemLink, profit = profit, mmValue = itemMMValue, transformValue = transformValue})
		end
	end
	
	table.sort(sellData, uespLog.CompareRawPriceData)
	
	for _, itemData in pairs(sellData) do
		local transformValue = string.format("%0.1f", itemData.transformValue)
		local itemMMValue = string.format("%0.1f", itemData.mmValue)
		local profit = string.format("%0.1f", itemData.profit)
		
		uespLog.Msg(".   "..tostring(itemData.itemLink)..": "..tostring(profit).." gold profit ("..tostring(transformValue).." refined, "..tostring(itemMMValue).." raw)")
	end
		
end


SLASH_COMMANDS["/uesprawprice"] = uespLog.CompareRawPrices


function uespLog.CompareRawPriceData(a, b)
	return a.profit < b.profit
end


function uespLog.ShowBaseRawPrices()
	local silkValue = uespLog.GetTrackLootTransformValue("Raw Ancestor Silk", 1, true)
	local leatherValue = uespLog.GetTrackLootTransformValue("Rubedo Hide Scraps", 1, true)
	local oreValue = uespLog.GetTrackLootTransformValue("Rubedite Ore", 1, true)
	local woodValue = uespLog.GetTrackLootTransformValue("Rough Ruby Ash", 1, true)
	
	silkValue = string.format("%0.1f", silkValue)
	leatherValue = string.format("%0.1f", leatherValue)
	oreValue = string.format("%0.1f", oreValue)
	woodValue = string.format("%0.1f", woodValue)
	
	uespLog.Msg("Showing base raw material prices:")
	uespLog.Msg(".          Silk: "..tostring(silkValue).." gold")
	uespLog.Msg(".    Leather: "..tostring(leatherValue).." gold")
	uespLog.Msg(".          Ore: "..tostring(oreValue).." gold")
	uespLog.Msg(".      Wood: "..tostring(woodValue).." gold")
	
end


-- Begin Overridden functions from esoui\ingame\characterwindow\keyboard\characterwindow_keyboard.lua
-- TODO: Is there a way to not override/copy these functions?
-- ZO_CharacterWindowStatsScrollScrollChildStatEntry25
function uespLog.ZO_CharacterWindowStats_ShowComparisonValues(bagId, slotId)
    local statDeltaLookup = ZO_GetStatDeltaLookupFromItemComparisonReturns(CompareBagItemToCurrentlyEquipped(bagId, slotId))
	
    for _, statGroup in ipairs(ZO_INVENTORY_STAT_GROUPS) do
        for _, stat in ipairs(statGroup) do
            local statDelta = statDeltaLookup[stat]
			
            if statDelta then
                --local statControl = CHARACTER_STAT_CONTROLS[stat]
				local statControl = _G['ZO_CharacterWindowStatsScrollScrollChildStatEntry' .. tostring(stat)]
				
				if (statControl ~= nil) then
					statControl.statEntry:ShowComparisonValue(statDelta)
				end
            end
        end
    end
	
end


function uespLog.ZO_CharacterWindowStats_HideComparisonValues()

    for _, statGroup in ipairs(ZO_INVENTORY_STAT_GROUPS) do
        for _, stat in ipairs(statGroup) do
            --local statControl = CHARACTER_STAT_CONTROLS[stat]
			local statControl = _G['ZO_CharacterWindowStatsScrollScrollChildStatEntry' .. tostring(stat)]
			
			if (statControl ~= nil) then
				statControl.statEntry:HideComparisonValue()
			end
        end
    end
	
end


function uespLog:ZO_StatEntry_Keyboard_GetDisplayValue(targetValue)
    local value = targetValue or self:GetValue()
    local statType = self.statType

	if (statType <= -100) then
	   return value
    elseif(statType == STAT_CRITICAL_STRIKE or statType == STAT_SPELL_CRITICAL) then
        return zo_strformat(SI_STAT_VALUE_PERCENT, GetCriticalStrikeChance(value))
    else
        return zo_strformat(SI_NUMBER_FORMAT, ZO_CommaDelimitNumber(value))
    end
end
-- End of Overridden functions from esoui\ingame\characterwindow\keyboard\characterwindow_keyboard.lua


-- Begin Overridden function from esoui\ingame\stats\keyboard\zo_statentry_keyboard.lua
-- TODO: Is there a way to not override/copy this function?
function uespLog:ZO_StatEntry_Keyboard_ShowComparisonValue(statDelta)

    if statDelta and statDelta ~= 0 then
        local comparisonStatValue = self:GetValue() + statDelta
        local color
        local icon
		
        if statDelta > 0 then
            color = ZO_SUCCEEDED_TEXT
            icon = "EsoUI/Art/Buttons/Gamepad/gp_upArrow.dds"
        else
            color = ZO_ERROR_COLOR
            icon = "EsoUI/Art/Buttons/Gamepad/gp_downArrow.dds"
        end

		if (uespLog.GetInventoryStatsConfig() == "custom") then
			comparisonValueString = "" .. color:Colorize(self:GetDisplayValue(statDelta).. " " .. zo_iconFormatInheritColor(icon, 24, 24) .. self:GetDisplayValue(comparisonStatValue))
		else
			comparisonValueString = zo_iconFormatInheritColor(icon, 24, 24) .. self:GetDisplayValue(comparisonStatValue)
			comparisonValueString = color:Colorize(comparisonValueString)	
		end
		
		--comparisonValueString = "" .. color:Colorize(self:GetDisplayValue(statDelta) .. " " .. zo_iconFormatInheritColor(icon, 24, 24) .. self:GetDisplayValue(self:GetValue()))

		self.currentStatDelta = statDelta
        self.control.value:SetHidden(true)
        self.control.comparisonValue:SetHidden(false)
        self.control.comparisonValue:SetText(comparisonValueString)
    end
end
--End of Overridden function from esoui\ingame\stats\keyboard\zo_statentry_keyboard.lua


-- Item subtypes that crash with GetItemLinkTraitOnUseAbilityInfo() in update 10
uespLog.BAD_TRAIT_ITEMTYPES = {
		[0] = true,
		[10] = true,
		[12] = true,
		[13] = true,
		[14] = true,
		[15] = true,
		[16] = true,
		[17] = true,
		[18] = true,
		[30] = true,
		[35] = true,
		[36] = true,
		[37] = true,
		[38] = true,
		[176] = true,
			[178] = true,
			[179] = true,
			[180] = true,
		[181] = true,
			[182] = true,
			[183] = true,
			[184] = true,
			[185] = true,
			[186] = true,
		[187] = true,
		[241] = true,
			[242] = true,
			[243] = true,
			[244] = true,
			[245] = true,
			[259] = true,
			[260] = true,
			[261] = true,
			[262] = true,
			[263] = true,
			[277] = true,
			[278] = true,
			[279] = true,
			[280] = true,
			[281] = true,
		[282] = true,
		[295] = true,
			[296] = true,
			[297] = true,
			[298] = true,
			[299] = true,
		[313] = true,
			[314] = true,
			[315] = true,
			[316] = true,
			[317] = true,
			[318] = true,
			[319] = true,
		[320] = true,
			[321] = true,
			[322] = true,
			[323] = true,
			[324] = true,
			[325] = true,
			[326] = true,
			[327] = true,
			[328] = true,
			[329] = true,
			[330] = true,
			[331] = true,
			[332] = true,
			[333] = true,
			[334] = true,
			[335] = true,
			[336] = true,
			[337] = true,
			[338] = true,
			[339] = true,
			[340] = true,
			[341] = true,
			[342] = true,
			[343] = true,
			[344] = true,
			[345] = true,
			[346] = true,
			[347] = true,
			[348] = true,
			[349] = true,
			[350] = true,
			[351] = true,
			[352] = true,
			[353] = true,
			[354] = true,
			[355] = true,
			[356] = true,
		[357] = true,
		[371] = true,
			[372] = true,
			[373] = true,
			[374] = true,
			[375] = true,
			[376] = true,
		[377] = true,
		[379] = true,
	}
	
	
	
function uespLog.testDumpRecipes()
	local logData
	local recipeCount = 0
	
	uespLog.Msg("Logging all recipe data...")
	
	logData = {}
	logData.event = "mineItem::Start"
	logData.note = "Only recipe data"
	uespLog.AppendDataToLog("all", logData)
	
	for itemId = 1, 115000 do
		local itemLink = uespLog.MakeItemLink(itemId, 1, 1)
		local itemType = GetItemLinkItemType(itemLink)
		
		if (itemType == 29) then
			logData = uespLog.CreateItemLinkLog(itemLink)
			
			logData.event = "mineItem"
			uespLog.AppendDataToLog("all", logData)
			
			uespLog.Msg(".        Logged data for "..itemLink.."...")
			recipeCount = recipeCount + 1
		end
	end
	
	logData = {}
	logData.event = "mineItem::End"
	uespLog.AppendDataToLog("all", logData)
	
	uespLog.Msg("Found and logged "..recipeCount.." recipes!")
end


function uespLog.OnPlayerCombatState(eventCode, inCombat)
	--uespLog.DebugMsg("OnPlayerCombatState: "..tostring(inCombat))
	
	if (not inCombat) then
		zo_callLater(uespLog.ClearRecentFightData, 500) 
	end
end


function uespLog.OnUnitCreated(eventCode, unitTag)
	uespLog.DebugExtraMsg("OnUnitCreated: "..tostring(unitTag))
end


function uespLog.OnUnitDestroyed(eventCode, unitTag)
	uespLog.DebugExtraMsg("OnUnitDestroyed: "..tostring(unitTag))
end


uespLog.RecentFightTargetIds = {}
uespLog.RecentFightTargetData = {}
uespLog.TargetHealthData = {}
uespLog.FightKillData = {}


function uespLog.ClearRecentFightData()
	uespLog.RecentFightTargetIds = {}
	uespLog.RecentFightTargetData = {}
end


function uespLog.UpdateTargetHealthData(targetName, unitTag, maxHealth)
	uespLog.TargetHealthData[targetName] = maxHealth
end


function uespLog.ClearTargetHealthData()
	uespLog.TargetHealthData = {}
end


function uespLog.UpdateRecentFightTargetId(targetId, targetName)

	if (targetId == 0 or targetName == "") then
		return
	end

	uespLog.RecentFightTargetIds[targetId] = targetName
end


function uespLog.UpdateFightTargetDeath(targetId, targetName)

	if (not uespLog.GetTrackFights()) then
		return
	end
	
	if (targetId == 0 and targetName == "") then
		return
	end
		
	if (targetName == "") then
		targetName = uespLog.RecentFightTargetIds[targetId]
		
		if (targetName == nil) then
			uespLog.DebugExtraMsg("UpdateFightTargetDeath: No targetName found for "..tostring(targetId).."!")
			return
		end
	end
	
	uespLog.DebugExtraMsg("UpdateFightTargetDeath: "..tostring(targetName).." ("..tostring(targetId)..")")	
	
	if (uespLog.FightKillData[targetName] == nil) then
		uespLog.FightKillData[targetName] = {}
		uespLog.FightKillData[targetName].fullName = targetName
		uespLog.FightKillData[targetName].name = targetName:gsub("%^.*", "")
		uespLog.FightKillData[targetName].count = 0
		uespLog.FightKillData[targetName].health = 0
	end
	
	
	if (uespLog.FightKillData[targetName].health == 0) then
		uespLog.FightKillData[targetName].health = uespLog.TargetHealthData[uespLog.FightKillData[targetName].name] or 0
	end
	
	uespLog.FightKillData[targetName].count = uespLog.FightKillData[targetName].count + 1
end


function uespLog.OnZoneUpdate(eventCode, unitTag, newZoneName)
	uespLog.DebugExtraMsg("OnZoneUpdate: "..tostring(unitTag)..", "..tostring(newZoneName))
end


function uespLog.ClearFightData()
	uespLog.ClearTargetHealthData()
	uespLog.ClearRecentFightData()
	
	uespLog.savedVars.charInfo.data.fightData = {}
	uespLog.FightKillData = uespLog.savedVars.charInfo.data.fightData
end


function uespLog.ShowFightData()
	local i = 0
	local totalKills = 0
	local totalHealth = 0
	local nameKeys = {}
	
	uespLog.Msg("Showing all current fight kill data:")
	
	for name in pairs(uespLog.FightKillData) do
		table.insert(nameKeys, name)
	end
	
	table.sort(nameKeys)

	for _, name in ipairs(nameKeys) do
		local data = uespLog.FightKillData[name]
		
		if (data.health == 0) then 
			data.health = uespLog.TargetHealthData[data.name] or 0
		end
		
		local health = data.health
		if (health == 0) then health = "?" end
		
		i = i + 1
		
		uespLog.Msg(".    "..tostring(i)..") "..tostring(data.name).." x"..tostring(data.count).." ("..tostring(data.health).." Health)")
		
		totalKills = totalKills + data.count
		totalHealth = totalHealth + data.health * data.count
	end
	
	uespLog.Msg("Found "..tostring(totalKills).." kills with a total of "..tostring(totalHealth).." Health.")
end


function uespLog.FightDataCommand(cmd)
	local cmds, firstCmd = uespLog.SplitCommands(cmd)
	
	if (firstCmd == "reset" or firstCmd == "clear") then
		uespLog.ClearFightData()
		uespLog.Msg("Cleared kill data!")
	elseif (firstCmd == "" or firstCmd == "show" or firstCmd == "list") then
		uespLog.ShowFightData()
	elseif (firstCmd == "on") then
		uespLog.SetTrackFights(true)
		uespLog.Msg("Turning kill data tracking on.")
	elseif (firstCmd == "off") then
		uespLog.SetTrackFights(false)
		uespLog.Msg("Turning kill data tracking off.")
	else
		uespLog.Msg("Collects and views data related to killing NPCs:")
		uespLog.Msg(".     /uespkilldata [on||off]")
		uespLog.Msg(".     /uespkilldata reset")
		uespLog.Msg(".     /uespkilldata")
		
		uespLog.Msg("Kill data tracking is currently "..uespLog.BoolToOnOff(uespLog.GetTrackFights())..".")
	end
	
end


SLASH_COMMANDS["/uespkilldata"] = uespLog.FightDataCommand


function uespLog.CheckAutoOpenContainer(bagId, slotIndex)

	uespLog.DebugExtraMsg("CheckAutoOpenContainer: "..tostring(bagId)..", "..tostring(slotIndex))

	if (true) then
		return
	end
	
	local itemName = GetItemName(bagId, slotIndex)
	local itemLink = GetItemLink(bagId, slotIndex)
	
	--("|H(.-):(.-):(.-):(.-):(.-):(.-)|h(.-)|h")
	--.("Crafting Motifs ([%d]+), [%a%.]+ ([%d]+): ([%a%s]+) ([%a]+)")
		
	local craftType, container, level = itemName:match("^(%S+) (%S+) (%S+)")
	--uespLog.DebugMsg(".     "..tostring(craftType)..", "..tostring(container)..", "..tostring(level))
	
	if (craftType ~= nil and container ~= nil) then
	
		if (container == "Pack" or container == "Crate" or container == "Coffer" or 
			container == "Case" or container == "Satchel" or container == "Vessel") then
			
			uespLog.DebugMsg("Automatically opening writ reward...")
			uespLog.OpenInventoryContainer(bagId, slotIndex, itemLink)
		elseif (craftType == "Shipment" and container == "of") then
			uespLog.DebugMsg("Automatically opening material shipment..."..tostring(bagId)..","..tostring(slotIndex))
			zo_callLater(function() uespLog.OpenInventoryContainer(bagId, slotIndex, itemLink) end, 1000)
		end
	end
	
	--if (itemName:match("^.+ Pack [VIX]") ~= nil) then
		--uespLog.DebugMsg("Opening writ reward...")
	--elseif (itemName:match("^.+ Crate [VIX]") ~= nil) then
		--uespLog.DebugMsg("Opening writ reward...")
	--elseif (itemName:match("^.+ Coffer [VIX]") ~= nil) then
		--uespLog.DebugMsg("Opening writ reward...")
	--elseif (itemName:match("^.+ Case [VIX]") ~= nil) then
		--uespLog.DebugMsg("Opening writ reward...")
	--elseif (itemName:match("^.+ Satchel [VIX]") ~= nil) then
		--uespLog.DebugMsg("Opening writ reward...")
	--elseif (itemName:match("^.+ Vessel [VIX]") ~= nil) then
		--uespLog.DebugMsg("Opening writ reward...")		
	--end
	
end


function uespLog.OpenInventoryContainer(bagId, slotIndex, itemLink)

	uespLog.OnUseItem("", bagId, slotIndex, itemLink, -1)

	if IsProtectedFunction("UseItem") then
		CallSecureProtected("UseItem", bagId, slotIndex)
	else
		UseItem(bagId, slotIndex)
	end
	
	SCENE_MANAGER:Hide("inventory")
	--zo_callLater(function() SCENE_MANAGER:Hide("inventory") end, 100)
end


function uespLog.IsNirncruxItem(itemLink)
	local _, _, itemId = uespLog.ParseLinkID(itemLink)
	
	if (itemId == "56863" or itemId == "56862") then
		return true
	end	
	
	return false
end


function uespLog.PlayNirncruxSound()

	if (not uespLog.GetNirnSound()) then
		return
	end
	
	PlaySound(SOUNDS.ENCHANTING_EXTRACT_START_ANIM)
end


function uespLog.NirnSoundCommand(cmd)
	local cmds, firstCmd = uespLog.SplitCommands(cmd)
	
	if (firstCmd == "on") then
		uespLog.SetNirnSound(true)
		uespLog.Msg("Playing of sound when looting Nirncrux is now On.")
	elseif (firstCmd == "off") then
		uespLog.SetNirnSound(false)
		uespLog.Msg("Playing of sound when looting Nirncrux is now Odd.")
	else
		uespLog.MsgColor(uespLog.craftColor, "Toggles the playing of a sound when you loot a Nirncruz item.")
		uespLog.MsgColor(uespLog.craftColor, ".       /uespnirnsound [on||off]")
		uespLog.Msg("Playing of sound when looting Nirncrux is "..uespLog.BoolToOnOff(uespLog.GetNirnSound()))
	end	
	
end


SLASH_COMMANDS["/uespnirnsound"] = uespLog.NirnSoundCommand


uespLog.FindNameChangeItemId = 1
uespLog.FindNameChangeIsScanning = false
uespLog.FindNameChangeScanIds = 2000
uespLog.FindNameChangeScanEndId = 200000
uespLog.FindNameChangeScanDelayMS = 1000
uespLog.FindNameChangeItemCount = 0


		
uespLog.FindNameChangeLevelData = {		
	{  1,   1 }, {  2,   1 }, {  3,   1 }, {  4,   1 }, {  5,   1 }, {  6,   1 }, {  7,   1 }, {  8,   1 }, {  9,   1 }, { 10,   1 },
	{ 11,   1 }, { 12,   1 }, { 13,   1 }, { 14,   1 }, { 15,   1 }, { 16,   1 }, { 17,   1 }, { 18,   1 }, { 19,   1 }, { 20,   1 },
	{ 21,   1 }, { 22,   1 }, { 23,   1 }, { 24,   1 }, { 25,   1 }, { 26,   1 }, { 27,   1 }, { 28,   1 }, { 29,   1 }, { 30,   1 },
	{ 31,   1 }, { 32,   1 }, { 33,   1 }, { 34,   1 }, { 35,   1 }, { 36,   1 }, { 37,   1 }, { 38,   1 }, { 39,   1 }, { 40,   1 },
	{ 41,   1 }, { 42,   1 }, { 43,   1 }, { 44,   1 }, { 45,   1 }, { 46,   1 }, { 47,   1 }, { 48,   1 }, { 49,   1 }, { 50,   1 },
	{ 50,  51 }, { 50,  52 }, { 50,  53 }, { 50,  54 }, { 50,  55 }, { 50,  56 }, { 50,  57 }, { 50,  58 }, { 50,  59 }, { 50,  60 },
	{ 50, 228 }, { 50, 246 }, { 50, 264 }, { 50, 282 }, { 50, 300 }, { 50, 358 },
}


function uespLog.FindMinedItemNameChangeStart()

	if (uespLog.FindNameChangeIsScanning) then
		uespLog.Msg("Already looking for item name changes...")
		return
	end
	
	uespLog.FindNameChangeItemId = 1
	uespLog.FindNameChangeItemCount = 0
	uespLog.FindNameChangeIsScanning = true
	
	uespLog.FindMinedItemNameChange()
end


function uespLog.FindMinedItemNameChangeEnd()
	uespLog.FindNameChangeIsScanning = false
end


function uespLog.FindMinedItemNameChangeLog(itemId)
	local lastName = ""
	local tempData = uespLog.savedVars.tempData.data
	
	for i, data in ipairs(uespLog.FindNameChangeLevelData) do
		local itemLink = uespLog.MakeItemLink(itemId, data[1], data[2])
		local itemName = GetItemLinkName(itemLink)
		local reqLevel = GetItemLinkRequiredLevel(itemLink)
		local reqCp = GetItemLinkRequiredChampionPoints(itemLink)
		local level = reqLevel
		
		if (reqCp > 0) then
			level = 50 + math.floor(reqCp/10)
		end
		
		if (itemName ~= lastName) then
			lastName = itemName
			tempData[#tempData + 1] = tostring(itemId)..","..tostring(level)..",'"..tostring(itemName).."'"
		end
	end
	
end


function uespLog.FindMinedItemNameChange()
	local startItemId = uespLog.FindNameChangeItemId
	local endItemId = startItemId + uespLog.FindNameChangeScanIds
	
	if (not uespLog.FindNameChangeIsScanning) then
		return
	end
	
	if (endItemId > uespLog.FindNameChangeScanEndId) then
		endItemId = uespLog.FindNameChangeScanEndId
	end
	
	uespLog.Msg("Looking for mined items "..tostring(startItemId).."-"..tostring(endItemId).." with name changes ("..tostring(uespLog.FindNameChangeItemCount).." so far)...")

	for itemId = startItemId, endItemId do
		local itemLink1 = uespLog.MakeItemLink(itemId, 1, 1)
		local itemLink2 = uespLog.MakeItemLink(itemId, 50, 370)
		local itemName1 = GetItemLinkName(itemLink1)
		local itemName2 = GetItemLinkName(itemLink2)
		
		if (itemName1 ~= itemName2) then
			uespLog.FindNameChangeItemCount = uespLog.FindNameChangeItemCount + 1
			uespLog.FindMinedItemNameChangeLog(itemId)
		end
		
	end
		
	uespLog.FindNameChangeItemId = endItemId + 1
	
	if (uespLog.FindNameChangeItemId < uespLog.FindNameChangeScanEndId) then
		zo_callLater(uespLog.FindMinedItemNameChange, uespLog.FindNameChangeScanDelayMS)
	else
		uespLog.Msg("Found "..tostring(uespLog.FindNameChangeItemCount).." items with name changes...")
	end
end


SLASH_COMMANDS["/uesptestwrit"] = function (cmd)
	local itemData = {}
	local cmds, firstCmd = uespLog.SplitCommands(cmd)
		
	itemData.itemId = cmds[1]
	itemData.inttype = 6
	itemData.level = 1
	itemData.writ1 = cmds[2] or 0
	itemData.writ2 = cmds[3] or 0
	itemData.writ3 = cmds[4] or 0
	itemData.writ4 = cmds[5] or 0
	itemData.writ5 = cmds[6] or 0
	itemData.writ6 = cmds[7] or 0
	itemData.vouchers = cmds[8] or 1000
	
	local itemLink = uespLog.MakeItemLinkEx(itemData)
	
	uespLog.Msg("UESP: Make test link ".. itemLink)
	ZO_PopupTooltip_SetLink(itemLink)
end


function uespLog.ZO_InventorySlot_OnMouseExit(inventorySlot)

	if (SYSTEMS:IsShowing("alchemy") and uespLog.GetCraftAlchemyTooltipDisplay()) then
		ZO_PopupTooltip_Hide()	
	end
	
	return uespLog.Old_ZO_InventorySlot_OnMouseExit(inventorySlot)
end


function uespLog.ZO_InventorySlot_OnMouseEnter(inventorySlot)

	if (not SYSTEMS:IsShowing("alchemy") or not uespLog.GetCraftAlchemyTooltipDisplay()) then
		return uespLog.Old_ZO_InventorySlot_OnMouseEnter(inventorySlot)
	end
	
	local buttonPart = inventorySlot
    local listPart
    local multiIconPart

    local controlType = inventorySlot:GetType()
    if controlType == CT_CONTROL and buttonPart.slotControlType and buttonPart.slotControlType == "listSlot" then
        listPart = inventorySlot
        buttonPart = inventorySlot:GetNamedChild("Button")
        multiIconPart = inventorySlot:GetNamedChild("MultiIcon")
    elseif controlType == CT_BUTTON then
        listPart = buttonPart:GetParent()
    end

 	local slotIndex = buttonPart.slotIndex
	local bagId = buttonPart.bagId
	
	if (slotIndex ~= nil and bagId ~= nil) then
		local itemLink = GetItemLink(bagId, slotIndex)
		
		if (PopupTooltip.lastLink ~= itemLink) then
			ZO_PopupTooltip_SetLink(itemLink)
		end
		
		return true
	end
	
	return uespLog.Old_ZO_InventorySlot_OnMouseEnter(inventorySlot)
end


function uespLog.MineItemSingle(itemId, internalLevel, internalSubtype)
	local itemLink = uespLog.MakeItemLinkEx( { itemId = itemId, level = internalLevel, quality = internalSubtype, style = 0 } )
		
	uespLog.LogItemLink(itemLink, "mineitem")
end


function uespLog.UseCustomTraitResearchCheck()
	return uespLog.GetMaxQualityForTraitResearch() > 0 and not uespLog.GetIncludeSetItemsForTraitResearch()
end

		
function uespLog.GetMaxQualityForTraitResearch()

	if (uespLog.savedVars.settings == nil) then
		uespLog.savedVars.settings = uespLog.DEFAULT_SETTINGS
	end
	
	if (uespLog.savedVars.settings.data.maxQualityForTraitResearch == nil) then
		uespLog.savedVars.settings.data.maxQualityForTraitResearch = uespLog.DEFAULT_SETTINGS.data.maxQualityForTraitResearch
	end
	
	return uespLog.savedVars.settings.data.maxQualityForTraitResearch
end


function uespLog.SetMaxQualityForTraitResearch(value)

	if (uespLog.savedVars.settings == nil) then
		uespLog.savedVars.settings = uespLog.DEFAULT_SETTINGS
	end
	
	uespLog.savedVars.settings.data.maxQualityForTraitResearch = value
end


function uespLog.GetIncludeSetItemsForTraitResearch()

	if (uespLog.savedVars.settings == nil) then
		uespLog.savedVars.settings = uespLog.DEFAULT_SETTINGS
	end
	
	if (uespLog.savedVars.settings.data.includeSetItemsForTraitResearch == nil) then
		uespLog.savedVars.settings.data.includeSetItemsForTraitResearch = uespLog.DEFAULT_SETTINGS.data.includeSetItemsForTraitResearch
	end
	
	return uespLog.savedVars.settings.data.includeSetItemsForTraitResearch
end


function uespLog.SetIncludeSetItemsForTraitResearch(value)

	if (uespLog.savedVars.settings == nil) then
		uespLog.savedVars.settings = uespLog.DEFAULT_SETTINGS
	end
	
	uespLog.savedVars.settings.data.includeSetItemsForTraitResearch = value
end


function uespLog.CanItemBeTraitResearched(bagId, slotIndex, craftingType, researchLineIndex, traitIndex)
	local maxQuality = uespLog.GetMaxQualityForTraitResearch()

	if (IsItemPlayerLocked(bagId, slotIndex)) then
		return false
	end

	if (not CanItemBeSmithingTraitResearched(bagId, slotIndex, craftingType, researchLineIndex, traitIndex)) then
		return false
	end
	
	if (maxQuality > 0) then
		local itemLink = GetItemLink(bagId, slotIndex)
		local quality = GetItemLinkDisplayQuality(itemLink)
		
		if (quality > maxQuality) then
			return false
		end
	end
	
	if (not uespLog.GetIncludeSetItemsForTraitResearch()) then
		local itemLink = GetItemLink(bagId, slotIndex)
		local hasSet = GetItemLinkSetInfo(itemLink)
		
		if (hasSet) then
			return false
		end
	end
	
	return true
end


function uespLog.GetTraitIndexForItem(bagId, slotIndex, craftingType, researchLineIndex, numTraits)

    for traitIndex = 1, numTraits do
	
        if (uespLog.CanItemBeTraitResearched(bagId, slotIndex, craftingType, researchLineIndex, traitIndex)) then
            return traitIndex
        end
		
    end
	
    return nil
end


--ZO_SharedSmithingResearch:GenerateResearchTraitCounts
function uespLog:GenerateResearchTraitCounts(virtualInventoryList, craftingType, researchLineIndex, numTraits)

	if (not uespLog.UseCustomTraitResearchCheck()) then
		--return uespLog:Old_GenerateResearchTraitCounts(self, virtualInventoryList, craftingType, researchLineIndex, numTraits)
	end
	
    local counts
	
    for itemId, itemInfo in pairs(virtualInventoryList) do
        local traitIndex = uespLog.GetTraitIndexForItem(itemInfo.bag, itemInfo.index, craftingType, researchLineIndex, numTraits)
		
        if traitIndex then
            counts = counts or {}
            counts[traitIndex] = (counts[traitIndex] or 0) + 1
        end
    end
	
    return counts
end


-- ZO_SmithingResearchSelect:SetupDialog
function uespLog:ZO_SmithingResearchSelect_SetupDialog(craftingType, researchLineIndex, traitIndex)

	if (not uespLog.UseCustomTraitResearchCheck()) then
		--return uespLog.Old_ZO_SmithingResearchSelect_SetupDialog(self, craftingType, researchLineIndex, traitIndex)
	end
	
    local listDialog = ZO_InventorySlot_GetItemListDialog()
    local _, _, _, timeRequiredForNextResearchSecs = GetSmithingResearchLineInfo(craftingType, researchLineIndex)
    local formattedTime = ZO_FormatTime(timeRequiredForNextResearchSecs, TIME_FORMAT_STYLE_COLONS, TIME_FORMAT_PRECISION_TWELVE_HOUR)
	
    listDialog:SetAboveText(GetString(SI_SMITHING_RESEARCH_DIALOG_SELECT))
    listDialog:SetBelowText(zo_strformat(SI_SMITHING_RESEARCH_DIALOG_CONSUME, formattedTime))
    listDialog:SetEmptyListText("")
    listDialog:ClearList()
	
    local function IsResearchableItem(bagId, slotIndex)
        return uespLog.CanItemBeTraitResearched(bagId, slotIndex, craftingType, researchLineIndex, traitIndex)
    end
	
    local virtualInventoryList = PLAYER_INVENTORY:GenerateListOfVirtualStackedItems(INVENTORY_BANK, IsResearchableItem, PLAYER_INVENTORY:GenerateListOfVirtualStackedItems(INVENTORY_BACKPACK, IsResearchableItem))
	
    for itemId, itemInfo in pairs(virtualInventoryList) do
        itemInfo.name = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetItemName(itemInfo.bag, itemInfo.index))
        listDialog:AddListItem(itemInfo)
    end
	
    listDialog:CommitList(SortComparator)
    listDialog:AddCustomControl(self.control, LIST_DIALOG_CUSTOM_CONTROL_LOCATION_BOTTOM)
end


function uespLog.MineBooks()
	local numCategories = GetNumLoreCategories()
	local totalBooks = 0
	local validBooks = 0
	local totalKnownBooks = 0
	local logEntry
	
	-- GetLoreBookIndicesFromBookId(number bookId)
	-- Returns: number:nilable categoryIndex, number:nilable collectionIndex, number:nilable bookIndex
	
	logEntry = {}
	logEntry.event = "mineBook:Start"
	uespLog.AppendDataToLog("all", logEntry, uespLog.GetTimeData())

	for categoryIndex = 1, numCategories do
		local name1, numCollections, categoryId = GetLoreCategoryInfo(categoryIndex)
		
		logEntry = {}
		logEntry.event = "mineBook:Category"
		logEntry.name = name1
		logEntry.numCollections = numCollections
		logEntry.categoryId = categoryId
		logEntry.categoryIndex = categoryIndex
		uespLog.AppendDataToLog("all", logEntry)
		
		for collectionIndex = 1, numCollections do
			local name2, desc, numKnownBooks, numBooks, hidden, collectionIcon, collectionId = GetLoreCollectionInfo(categoryIndex, collectionIndex)
			
			logEntry = {}
			logEntry.event = "mineBook:Collection"
			logEntry.name = name2
			logEntry.collectionIndex = collectionIndex
			logEntry.categoryIndex = categoryIndex
			logEntry.desc = desc
			logEntry.numBooks = numBooks
			logEntry.hidden = hidden
			logEntry.icon = collectionIcon
			logEntry.collectionId = collectionId
			uespLog.AppendDataToLog("all", logEntry)
			
			totalBooks = totalBooks + numBooks
			totalKnownBooks = totalKnownBooks + numKnownBooks
			
			for bookIndex = 1, numBooks do
				local title, bookIcon, known, bookId = GetLoreBookInfo(categoryIndex, collectionIndex, bookIndex)
				local body, medium, showTitle = ReadLoreBook(categoryIndex, collectionIndex, bookIndex)
				local itemLink = GetLoreBookLink(categoryIndex, collectionIndex, bookIndex)
				
				if (body ~= "") then
					validBooks = validBooks + 1
				end
				
				logEntry = {}
				logEntry.event = "mineBook"
				logEntry.bookId = bookId
				logEntry.title = title
				logEntry.medium = medium
				logEntry.icon = bookIcon
				logEntry.categoryIndex = categoryIndex
				logEntry.collectionIndex = collectionIndex
				logEntry.bookIndex = bookIndex
				logEntry.itemLink = itemLink
				
				uespLog.AppendDataToLog("all", logEntry)
			end
			
		end
	end
	
	logEntry = {}
	logEntry.event = "mineBook:End"
	logEntry.validBooks = validBooks
	logEntry.totalBooks = totalBooks
	logEntry.totalKnownBooks = totalKnownBooks
	uespLog.AppendDataToLog("all", logData, uespLog.GetTimeData())
	
	uespLog.Msg("Found "..validBooks.." / "..totalBooks.." books with "..totalKnownBooks.." known!")
end


uespLog.MineRecipeStartId = 1
uespLog.MineRecipeCount = 0
uespLog.MineRecipeResultIds = {}


function uespLog.MineRecipeDataStart()
	local tempData = uespLog.savedVars.tempData.data
	
	tempData[#tempData + 1] = "Recipe Data..."
	
	uespLog.MineRecipeStartId = 1
	uespLog.MineRecipeCount = 0
	uespLog.MineRecipeResultIds = {}
	
	uespLog.MineRecipeData_Loop()
end


function uespLog.MineRecipeDataEnd()
	local tempData = uespLog.savedVars.tempData.data
	local numRecipeLists = GetNumRecipeLists()
	local recipeCount = 0
	local knownCount = 0
	local parsedResultIds = {}
	
	for recipeListIndex = 1, numRecipeLists do
		local listName, numRecipes, upIcon, downIcon, overIcon, disabledIcon = GetRecipeListInfo(recipeListIndex)
		
		--tempData[#tempData + 1] = "LIST: "..recipeListIndex..","..listName..","..numRecipes..","..upIcon..","..downIcon..","..overIcon..","..disabledIcon
		tempData[#tempData + 1] = "" .. recipeListIndex .. " => array(" .. numRecipes .. ", \"" .. listName .. "\", \"" .. upIcon .. "\", " .. '1' .. "),"
	end
	
	for recipeListIndex = 1, numRecipeLists do
		local listName, numRecipes, upIcon, downIcon, overIcon, disabledIcon = GetRecipeListInfo(recipeListIndex)
		
		for recipeIndex = 1, numRecipes do
			local known, name = GetRecipeInfo(recipeListIndex, recipeIndex)
	
			if (known and name ~= "") then
				local resultLink = GetRecipeResultItemLink(recipeListIndex, recipeIndex)
				local resultId = uespLog.ParseLinkItemId(resultLink)
				
				knownCount = knownCount + 1
				
				if (resultId > 0) then
					parsedResultIds[resultId] = 1
					local itemId = uespLog.MineRecipeResultIds[resultId] or -1
					local resultName = GetItemLinkName(resultLink)
					local quality = GetItemLinkDisplayQuality(resultLink)
					
					tempData[#tempData + 1] = "" .. resultId .. " => array(" .. itemId .. ", \"" .. listName .. "\", \"" .. resultName .. "\", " .. tostring(quality) .. "),"
				else
					--tempData[#tempData + 1] = "-1 = -1," .. listName
				end
			end
			
			recipeCount = recipeCount + 1
		end
	end
	
	for resultId, itemId in pairs(uespLog.MineRecipeResultIds) do
	
		if (parsedResultIds[resultId] == nil) then
			local resultLink = uespLog.MakeItemLink(resultId, 1, 1)
			local itemLink = uespLog.MakeItemLink(itemId, 1, 1)
			local resultName = GetItemLinkName(resultLink)
			local recipeType = "Unknown"
			local furnDataID = GetItemLinkFurnitureDataId(resultLink)
			local itemType, specialType = GetItemLinkItemType(resultLink)
			local furnCate, furnSubCate = GetFurnitureDataCategoryInfo(furnDataID)
			local furnCateName = GetFurnitureCategoryName(furnCate)
			local furnSubCateName = GetFurnitureCategoryName(furnSubCate)
			local quality = GetItemLinkDisplayQuality(resultLink)
			
			if (furnCateName ~= "") then
				recipeType = furnCateName
			end
			
			tempData[#tempData + 1] = "" .. resultId .. " => array(" .. itemId .. ", \"" .. recipeType .. "\", \"" .. resultName .. "\", " .. tostring(quality) .. "),"
		end
		
	end

end


function uespLog.MineRecipeData_Loop()
	local tempData = uespLog.savedVars.tempData.data
	local endItemId = uespLog.MineRecipeStartId + 10000
	
	uespLog.Msg("Mining recipe data starting at " .. uespLog.MineRecipeStartId .. "...")
		
	for itemId = uespLog.MineRecipeStartId, endItemId do
		local itemLink = uespLog.MakeItemLink(itemId, 1, 1)
		
		if (uespLog.IsValidItemLink(itemLink)) then
			local itemType = GetItemLinkItemType(itemLink)
			
			if (itemType == 29) then
				local resultLink = GetItemLinkRecipeResultItemLink(itemLink)
				local itemId = uespLog.ParseLinkItemId(itemLink)
				local resultId = uespLog.ParseLinkItemId(resultLink)
				
				uespLog.MineRecipeResultIds[resultId] = itemId
				
				tempData[#tempData + 1] = "" .. resultId .. " = " .. itemId
				uespLog.MineRecipeCount = uespLog.MineRecipeCount + 1
			end
		end
	end
	
	if (endItemId < uespLog.MINEITEM_AUTO_MAXITEMID) then
		uespLog.MineRecipeStartId = endItemId + 1
		zo_callLater(uespLog.MineRecipeData_Loop, 1000)
	else
		uespLog.MineRecipeDataEnd()
		uespLog.Msg("Finished mining recipe data...found "..uespLog.MineRecipeCount.." recipes!")
	end
end


uespLog.LastUnreadMails = 0

function uespLog.OnMailNumUnreadChanged(event, numUnread)
	local isMailShowing = MAIL_INTERACTION_FRAGMENT:IsShowing()
	
	uespLog.DebugExtraMsg("OnMailNumUnreadChanged "..tostring(numUnread))
	
	if (numUnread > 0 and isMailShowing and numUnread > uespLog.LastUnreadMails) then
		uespLog.CheckHirelingMails()
		uespLog.LastUnreadMails = numUnread
	end

end


function uespLog.IsHirelingMail(mailId)
	local senderDisplayName, senderCharacterName, subject, icon, unread, fromSystem, fromCustomerService, returned, numAttachments, attachedMoney, codAmount, expiresInDays, secsSinceReceived = GetMailItemInfo(mailId)
	local tradeType = -1
		
	if (not fromSystem) then
		return false, tradeType, secsSinceReceived
	end
	
	if (subject == "Raw Provisioner Materials") then
		tradeType = CRAFTING_TYPE_PROVISIONING
	elseif (subject == "Raw Woodworker Materials") then
		tradeType = CRAFTING_TYPE_WOODWORKING
	elseif (subject == "Raw Blacksmith Materials") then
		tradeType = CRAFTING_TYPE_BLACKSMITHING
	elseif (subject == "Raw Enchanter Materials") then
		tradeType = CRAFTING_TYPE_ENCHANTING
	elseif (subject == "Raw Clothier Materials") then
		tradeType = CRAFTING_TYPE_CLOTHIER
	else
		return false, -1, secsSinceReceived
	end
	
	return true, tradeType, secsSinceReceived
end


function uespLog.CheckHirelingMails()
	local numMails = GetNumMailItems()
	local mailId = GetNextMailId()
	local timestamp = GetTimeStamp()
	
	while (mailId ~= nil) do
		local isHirelingMail, tradeType, secsSinceReceived = uespLog.IsHirelingMail(mailId)
		
		if (isHirelingMail) then
			local mailSentTime = timestamp - secsSinceReceived
			uespLog.savedVars.charInfo.data.hirelingMailTime[tradeType] = mailSentTime
		end
		
		mailId = GetNextMailId(mailId)	
	end
	
end


function uespLog.AutolootHirelingMails()
	local numMails = GetNumMailItems()
	local mailId = GetNextMailId()
	local numFound = 0
	local numLooted = 0
	
	uespLog.AutolootHireMailNumAttempts = 0
	
	while (mailId ~= nil) do
		local isHirelingMail = uespLog.IsHirelingMail(mailId)
		
		if (isHirelingMail) then
			numFound = numFound + 1
		
			if (uespLog.AutolootHirelingMail(mailId)) then
				numLooted = numLooted + 1
			end
		end
		
		mailId = GetNextMailId(mailId)	
	end
	
end


uespLog.AutolootHireMailNumAttempts = 0
uespLog.AutolootHireMailDelayMS = 100


function uespLog.AutolootHirelingMail(mailId)

	uespLog.DebugExtraMsg("Trying to autoloot hireling mail #"..tostring(mailId)..".")
	
	if (not IsReadMailInfoReady(mailId)) then
		uespLog.AutolootHireMailNumAttempts = uespLog.AutolootHireMailNumAttempts + 1
		uespLog.DebugExtraMsg(tostring(uespLog.AutolootHireMailNumAttempts)..": Hireling mail #"..tostring(mailId).." is not yet readable!")
		
		if (uespLog.AutolootHireMailNumAttempts >= 10) then
			uespLog.Msg("Failed to read hireling mail ID#"..tostring(mailId).." after 10 attempts!")
			return false
		end
		
		RequestReadMail(mailId)
		
		zo_callLater(function() uespLog.AutolootHirelingMail(mailId) end, uespLog.AutolootHireMailDelayMS)
		return false
	end
	
	uespLog.OnMailMessageTakeAttachedItem ("manual", mailId)
	
	TakeMailAttachedItems(mailId)
	TakeMailAttachedMoney(mailId)
	
	uespLog.AutolootHireMailNumAttempts = 0
	zo_callLater(function() uespLog.AutolootHirelingMailDelete(mailId) end, uespLog.AutolootHireMailDelayMS)
	
	return true
end


function uespLog.AutolootHirelingMailDelete(mailId)
	--local sender, senderChar, subject, icon, unread, system, service, returned = GetMailItemInfo(mailId)
	local numAttachments, attachedMoney, codAmount = GetMailAttachmentInfo(mailId)
	
	uespLog.DebugExtraMsg("Trying to auto-delete hireling mail #"..tostring(mailId)..".")
	
	if (numAttachments > 0 or attachedMoney > 0) then
		uespLog.AutolootHireMailNumAttempts = uespLog.AutolootHireMailNumAttempts + 1
		
		if (uespLog.AutolootHireMailNumAttempts >= 10) then
			uespLog.Msg("Not automatically deleting hireling mail #"..tostring(mailId).." as it still contains items/money!")
			return false
		end
		
		zo_callLater(function() uespLog.AutolootHirelingMailDelete(mailId) end, uespLog.AutolootHireMailDelayMS)
		
		return false
	end

	DeleteMail(mailId, true)

	uespLog.AutolootHireMailNumAttempts = 0	
	zo_callLater(function() uespLog.AutolootHirelingMailCheckDelete(mailId) end, uespLog.AutolootHireMailDelayMS)
end


function uespLog.AutolootHirelingMailCheckDelete(mailId)
	local sender = GetMailItemInfo(mailId)
	
	if (sender == nil or sender == "") then
		return true
	end
	
	uespLog.AutolootHireMailNumAttempts = uespLog.AutolootHireMailNumAttempts + 1
	
	if (uespLog.AutolootHireMailNumAttempts >= 10) then
		uespLog.Msg("Failed to delete hireling mail ID#"..tostring(mailId).." after 10 attempts!")
		return false
	end
	
	DeleteMail(mailId, true)
	
	zo_callLater(function() uespLog.AutolootHirelingMailCheckDelete(mailId) end, uespLog.AutolootHireMailDelayMS)
	return false
end


uespLog.CHECK_HIRELING_TRADES = {
	[CRAFTING_TYPE_BLACKSMITHING] = NON_COMBAT_BONUS_BLACKSMITHING_HIRELING_LEVEL, 
	[CRAFTING_TYPE_CLOTHIER] = NON_COMBAT_BONUS_CLOTHIER_HIRELING_LEVEL,
	[CRAFTING_TYPE_ENCHANTING] = NON_COMBAT_BONUS_ENCHANTING_HIRELING_LEVEL,
	[CRAFTING_TYPE_PROVISIONING] = NON_COMBAT_BONUS_PROVISIONING_HIRELING_LEVEL,
	[CRAFTING_TYPE_WOODWORKING] = NON_COMBAT_BONUS_WOODWORKING_HIRELING_LEVEL,
}


function uespLog.ShowHirelingTimes()
	local hireData = uespLog.savedVars.charInfo.data.hirelingMailTime
	local currentTime = GetTimeStamp()
	
	if (hireData == nil) then
		uespLog.Msg("No data available for hireling mails!")
		return
	end
	
	for trade, nonCombatBonus in pairs(uespLog.CHECK_HIRELING_TRADES) do
		local lastMailTime = hireData[trade] or 0
		local name = uespLog.GetCraftingName(trade)
		local hireLevel = GetNonCombatBonus(nonCombatBonus)
		local timePerMail = 24*3600
		
		if (hireLevel <= 0) then
			-- Do nothing
		elseif (lastMailTime > 0) then
			if (hireLevel >= 3) then timePerMail = 12 * 3600 end
			local timeLeft = lastMailTime + timePerMail - currentTime
			
			if (timeLeft <= 0) then
				uespLog.Msg(""..name.." hireling mail ready to receive!")
			else
				local hour = math.floor(timeLeft / 3600)
				local minute = math.floor((timeLeft / 60) % 60)
				local second = math.floor((timeLeft) % 60)
				local timeStr = string.format("%02d:%02d:%02d", hour, minute, second)
				
				uespLog.Msg(""..name.." hireling mail ready in "..timeStr..".")	
			end
		else
			uespLog.Msg("No data available for "..name.." hireling mails!")
		end
	end
end


function uespLog.CheckHirelingCommand(cmd)
	local cmds, firstCmd = uespLog.SplitCommands(cmd)
	
	if (firstCmd == "" or firstCmd == "show" or firstCmd == "list") then
		uespLog.ShowHirelingTimes()
	elseif (firstCmd == "autoloot") then
		local secondCmd = string.lower(cmds[2])
		
		if (secondCmd == "on") then
			uespLog.SetAutoLootHirelingMails(true)
			uespLog.Msg("Hireling mail autolooting is now ON.")
		elseif (secondCmd == "off") then
			uespLog.SetAutoLootHirelingMails(false)
			uespLog.Msg("Hireling mail autolooting is now OFF.")
		else
			uespLog.Msg("Hireling mail autolooting is currently "..uespLog.BoolToOnOff(uespLog.GetAutoLootHirelingMails())..".")
		end
		
	else
		uespLog.Msg(".       /uesphireling help           Show command help")
		uespLog.Msg(".       /uesphireling           Show next time for hireling mails")
		uespLog.Msg(".       /uesphireling autoloot [on||off]    Turn autolooting of mails on/off")
	end

end


SLASH_COMMANDS["/uesphireling"] = uespLog.CheckHirelingCommand
SLASH_COMMANDS["/uesphire"] = uespLog.CheckHirelingCommand


function uespLog.OnMailOpenMailbox(event)
	uespLog.DebugExtraMsg("OnMailOpenMailbox")
	uespLog.CheckHirelingMails()
	
	local firstMailId = GetNextMailId(nil)
	
	if (type(firstMailId) == "string") then
		return
	end
	
	RequestReadMail(firstMailId)
end


function uespLog.TeleportToPrimaryHome()
	local houseId = GetHousingPrimaryHouse()
	
	if (houseId == nil or houseId <= 0) then
		uespLog.Msg("You don't have a primary residence to teleport to!")
		return
	end
	
	uespLog.Msg("Trying to teleport to your primary residence...")
	RequestJumpToHouse(GetHousingPrimaryHouse())
end


SLASH_COMMANDS["/uesphome"] = uespLog.TeleportToPrimaryHome


function uespLog.GetCharQuestStageData()

	if (uespLog.savedVars.charInfo.data.questStageData == nil) then
		uespLog.savedVars.charInfo.data.questStageData = uespLog.DEFAULT_CHARINFO.data.questStageData
	end
	
	return uespLog.savedVars.charInfo.data.questStageData
end


function uespLog.GetCharQuestUniqueIds()

	if (uespLog.savedVars.charInfo.data.questUniqueIds == nil) then
		uespLog.savedVars.charInfo.data.questUniqueIds = uespLog.DEFAULT_CHARINFO.data.questUniqueIds
	end
	
	return uespLog.savedVars.charInfo.data.questUniqueIds
end

	-- TODO: Is there an API/constant for this?
uespLog.MAXCAMPAIGN = 100


function uespLog.FindCampaignId(name)
	name = name:lower()
	
	for i = 1, uespLog.MAXCAMPAIGN do 
		local name1 = tostring(GetCampaignName(i)):lower()
			
		if (name1 == name) then 
			return i
		end
	end
	
	return -1
end


function uespLog.GetCampaignIdToIndexTable()
	local numCampaigns = GetNumSelectionCampaigns()
	local result = {}
	
	for i = 1, numCampaigns do
		local campaignId = GetSelectionCampaignId(i)
		result[campaignId] = i
	end
	
	return result
end


function uespLog.ChangePVPCampaignCommand(cmd)
	QueryCampaignSelectionData()
	
	local cmds, firstCmd = uespLog.SplitCommands(cmd)
	local campaignId = tonumber(firstCmd)
	local campaignIdToIndex = uespLog.GetCampaignIdToIndexTable()
	local campaignName = cmd

	if (firstCmd == "help") then
		firstCmd = ""
		cmd = ""
		campaignName = ""
	end
		
	if (campaignId ~= nil) then
		campaignName = GetCampaignName(campaignId)
		uespLog.Msg("Queuing for the "..campaignName.." campaign...")
		QueueForCampaign(campaignId)
		return
	elseif (firstCmd == "list" or firstCmd == "listall") then
		local outputCount = 0
		uespLog.Msg("Listing all valid campaigns:")
	
		for i = 1, uespLog.MAXCAMPAIGN do 
			local name = tostring(GetCampaignName(i))
			local campaignIndex = campaignIdToIndex[i]
			local homeId = GetAssignedCampaignId()
			local guestId = GetGuestCampaignId()
			
			if (name ~= "") then
				local msg = ".    "..tostring(i)..": "..name
				
				if (campaignIndex ~= nil) then
					msg = msg .. " (open)"
					
					if (i == homeId) then
						msg = msg .. " home"
					elseif (i == guestId) then
						msg = msg .. " guest"
					end
					
					uespLog.Msg(msg)
					outputCount = outputCount + 1
				elseif (firstCmd == "listall") then
					uespLog.Msg(msg)
					outputCount = outputCount + 1
				end				

			end
		end
		
		if (outputCount == 0) then
			uespLog.Msg("No campaigns found...wait a few seconds and try again (waiting for campaign data to be received).")
		end
	
		return
		
	elseif (firstCmd == "home") then
		local campaignId = GetAssignedCampaignId()
		campaignName = GetCampaignName(campaignId)
		
		if (campaignId <= 0) then
			uespLog.Msg("You have no home campaign assigned!")
			return
		end
		
		uespLog.Msg("Queuing for the "..campaignName.." (home) campaign...")		
		QueueForCampaign(campaignId)
		
		return
	elseif (firstCmd == "quest") then
		local campaignId = GetGuestCampaignId()
		campaignName = GetCampaignName(campaignId)
		
		if (campaignId <= 0) then
			uespLog.Msg("You have no guest campaign assigned!")
			return
		end
		
		uespLog.Msg("Queuing for the "..campaignName.." (guest) campaign...")		
		QueueForCampaign(campaignId)
		
		return
	elseif (campaignName ~= "") then
		local msg = ""
		local playerAlliance = GetUnitAlliance("player")
		local guestId = GetGuestCampaignId()
		local homeId = GetAssignedCampaignId()
		
		campaignId = uespLog.FindCampaignId(campaignName)
		
		local campaignIndex = campaignIdToIndex[campaignId]
		
		if (campaignId <= 0) then
			uespLog.Msg("The campaign '"..campaignName.."' is not valid! Use '/uesppvpqueue list' to show all open campaigns.")
			return
		end		
		
		if (not DoesPlayerMeetCampaignRequirements(campaignId)) then
			msg = "You don't meet the requirements for the "..campaignName.." campaign but trying to queue for it anyways..."
		end
		
		if (campaignId ~= guestId and campaignId ~= homeId) then
			uespLog.Msg("Warning: The campaign '"..campaignName.."' is not your guest or home campaign (queuing probably won't work).")
		end
		
		if (campaignIndex == nil) then
			msg = "The "..campaignName.." campaign is not open but trying to queue for it anyways..."
		else
			local popCount = GetSelectionCampaignPopulationData(campaignIndex, playerAlliance)
			
			if (popCount == CAMPAIGN_POP_FULL) then
				msg = "The "..campaignName.." campaign may be full but trying to queue for it anyways..."
			end
		end
		
		--GetSelectionCampaignQueueWaitTime(number campaignIndex)
			--Returns: number queueWaitTimeSeconds
		
		if (msg == "") then
			msg = "Queuing for the "..campaignName.." campaign..."
		end
		
		uespLog.Msg(msg)
		
		QueueForCampaign(campaignId)
		return		
	end
	
	uespLog.Msg("Queues you for a specific PVP campaign.")
	uespLog.Msg("            /uesppvpqueue [name]        Queue using the campaign name")
	uespLog.Msg("            /uesppvpqueue [number]      Queue using the campaign ID")
	uespLog.Msg("            /uesppvpqueue home          Queue for your assigned home campaign")
	uespLog.Msg("            /uesppvpqueue guest         Queue for your assigned guest campaign")
	uespLog.Msg("            /uesppvpqueue list          List all open campaigns")
	uespLog.Msg("            /uesppvpqueue listall       List all known campaigns")
end


SLASH_COMMANDS["/uesppvpqueue"] = uespLog.ChangePVPCampaignCommand


function uespLog.MineBookTree()
	local tempData = uespLog.savedVars.tempData.data
	local numCategories = GetNumLoreCategories()
	local categoryIndex
	local collectionIndex
	local bookIndex
	local totalBooks = 0
	local validBooks = 0
	local totalKnownBooks = 0
	
	for categoryIndex = 1, numCategories do
		local name1, numCollections, categoryId = GetLoreCategoryInfo(categoryIndex)
		local totalCatBooks = 0
		
		name1 = name1:gsub("'", "`")
		
		for collectionIndex = 1, numCollections do
			local _, _, _, numBooks = GetLoreCollectionInfo(categoryIndex, collectionIndex)
			totalCatBooks = totalCatBooks + numBooks
		end
		
		tempData[#tempData + 1] = ""..tostring(categoryIndex).." => array("
		tempData[#tempData + 1] = "0 => array( 'id' => "..tostring(categoryId)..", 'name' => '"..tostring(name1).."', 'numCollect' => "..tostring(numCollections)..", 'numBooks' => "..tostring(totalCatBooks).." ),"
		
		for collectionIndex = 1, numCollections do
			local name2, desc, numKnownBooks, numBooks, hidden, collectionIcon, collectionId = GetLoreCollectionInfo(categoryIndex, collectionIndex)

			name2 = name2:gsub("'", "`")
			
			tempData[#tempData + 1] = ""..tostring(collectionIndex).." => array( 'id' => "..tostring(collectionId)..", 'name' => '"..tostring(name2).."', 'numBooks' => "..tostring(numBooks)..", 'icon' => '"..tostring(collectionIcon).."',"
						
			totalBooks = totalBooks + numBooks
			totalKnownBooks = totalKnownBooks + numKnownBooks
			
			tempData[#tempData + 1] = "'books' => array("
			
			for bookIndex = 1, numBooks do
				local title, bookIcon, known, bookId = GetLoreBookInfo(categoryIndex, collectionIndex, bookIndex)
				--local body, medium, showTitle = ReadLoreBook(categoryIndex, collectionIndex, bookIndex)
				--local itemLink = GetLoreBookLink(categoryIndex, collectionIndex, bookIndex)
				
				title = title:gsub("'", "`")
				
				tempData[#tempData + 1] = ""..tostring(bookId).." => array( 'title' => '"..tostring(title).."', 'icon' => '"..tostring(bookIcon).."'),"
				
				if (body ~= "") then
					validBooks = validBooks + 1
				end			
			end	
			
			tempData[#tempData + 1] = "),"
			tempData[#tempData + 1] = "),"
		end
		
		tempData[#tempData + 1] = "),"
	end
		
	uespLog.Msg("Found "..validBooks.." / "..totalBooks.." books with "..totalKnownBooks.." known!")
end


function uespLog.MineCollectibleTree()
	local tempData = uespLog.savedVars.tempData.data
	local numCategories = GetNumCollectibleCategories()
	local categoryIndex
	local subCategoryIndex
	local collectibleIndex
	local collectibleCount = 0
	local knownCount = 0
	
	for categoryIndex = 1, numCategories do
		local catName, numSubCategories, numCatCollectibles, unlocked, totalCollectibles = GetCollectibleCategoryInfo(categoryIndex)
		local special = GetCollectibleCategorySpecialization(categoryIndex)
		local icon = GetCollectibleCategoryKeyboardIcons(categoryIndex)
		
		catName = catName:gsub("'", "`")
		
		tempData[#tempData + 1] = ""..tostring(categoryIndex).." => array("
		tempData[#tempData + 1] = "0 => array( 'categoryIndex' => "..tostring(categoryIndex)..", 'name' => '"..tostring(catName).."', 'icon' => '"..tostring(icon).."', 'special' => "..tostring(special)..", 'numSubCategories' => "..tostring(numSubCategories)..", 'numCollectibles' => "..tostring(numCatCollectibles)..", "
		tempData[#tempData + 1] = "'collectibles' => array("
		
		for collectibleIndex = 1, numCatCollectibles do
			local collectibleId = GetCollectibleId(categoryIndex, nil, collectibleIndex)
			local name, desc, icon, _, unlocked, purchaseable, _, categoryType, hint = GetCollectibleInfo(collectibleId)
			local bgImage = GetCollectibleKeyboardBackgroundImage(collectibleId)
			local nickname = GetCollectibleNickname(collectibleId)
			
			collectibleCount = collectibleCount + 1
			
			if (unlocked) then
				knownCount = knownCount + 1	
			end
			
			name = name:gsub("'", "`")
			desc = desc:gsub("'", "`")
			nickname = nickname:gsub("'", "`")
			
			tempData[#tempData + 1] = ""..tostring(collectibleIndex).." => array( 'id' => "..tostring(collectibleId)..", 'name' => '"..tostring(name).."', 'icon' => '"..tostring(icon).."', 'desc' => '"..tostring(desc).."', 'type' => "..tostring(categoryType)..", 'image' => '"..tostring(bgImage).."', 'nickname' => '"..tostring(nickname).."'),"
		end
		
		tempData[#tempData + 1] = "),"
		tempData[#tempData + 1] = "),"
		
		for subCategoryIndex = 1, numSubCategories do
			local subCatName, numCollectibles, unlocked, totalCollectibles = GetCollectibleSubCategoryInfo(categoryIndex, subCategoryIndex)
			
			subCatName = subCatName:gsub("'", "`")
			
			tempData[#tempData + 1] = ""..tostring(subCategoryIndex).." => array( 'subCategoryIndex' => "..tostring(subCategoryIndex)..", 'name' => '"..tostring(subCatName).."', 'numCollectibles' => "..tostring(numCollectibles)..", "
			tempData[#tempData + 1] = "'collectibles' => array("
			
			for collectibleIndex = 1, numCollectibles do
				local collectibleId = GetCollectibleId(categoryIndex, subCategoryIndex, collectibleIndex)
				local name, desc, icon, _, unlocked, purchaseable, _, categoryType, hint = GetCollectibleInfo(collectibleId)
				local bgImage = GetCollectibleKeyboardBackgroundImage(collectibleId)
				local nickname = GetCollectibleNickname(collectibleId)
				
				collectibleCount = collectibleCount + 1
				
				if (unlocked) then
					knownCount = knownCount + 1	
				end
				
				name = name:gsub("'", "`")
				desc = desc:gsub("'", "`")
				nickname = nickname:gsub("'", "`")
				
				tempData[#tempData + 1] = ""..tostring(collectibleIndex).." => array( 'id' => "..tostring(collectibleId)..", 'name' => '"..tostring(name).."', 'icon' => '"..tostring(icon).."', 'desc' => '"..tostring(desc).."', 'type' => "..tostring(categoryType)..", 'image' => '"..tostring(bgImage).."', 'nickname' => '"..tostring(nickname).."'),"
			end

			tempData[#tempData + 1] = "),"
			tempData[#tempData + 1] = "),"
		end
		
		tempData[#tempData + 1] = "),"
	end
	
	uespLog.Msg("Found "..knownCount.." / "..collectibleCount.." collectibles!")
end


function uespLog.CheckAchievementForSkyshards(achievementId)
	local name = GetAchievementInfo(achievementId)
	local findIndex = name:find("Skyshard")
	
		-- 989 = Tamriel Skyshard Hunter
	if (findIndex == nil or achievementId == 989) then
		return 0, 0 
	end
	
	local totalSkyshards = GetAchievementNumCriteria(achievementId)
	local achLink = GetAchievementLink(achievementId)
	local _, progress, timestamp = uespLog.ParseAchievementLinkId(achLink)
	local foundSkyshards = uespLog.CountSetBits(progress)
					
	return foundSkyshards, totalSkyshards
end


uespLog.COUNT_SET_BITS = {
    ['0'] = 0,
    ['1'] = 1,
    ['2'] = 1,
    ['3'] = 2,
    ['4'] = 1,
    ['5'] = 2,
    ['6'] = 2,
    ['7'] = 3,
}


function uespLog.CountSetBits(value)
	local s = string.format("%o", value)
	local result = 0
	
	for i = 1, #s do
		local c = s:sub(i,i)
		local value = uespLog.COUNT_SET_BITS[c]
		
		if (value ~= nil) then
			result = result + value
		end
	end
	
	return result
end


function uespLog.GetSkyshardsFound()
	local totalSkyshards = 1	-- One in wailing prison not in achievements
	local foundSkyshards = 0
	local topLevelIndex
	local numTopLevelCategories = GetNumAchievementCategories()
	local categoryIndex
	local achievementIndex
	
	for topLevelIndex = 1, numTopLevelCategories do
		local cateName, numCategories, numCateAchievements, earnedPoints, totalPoints, hidesPoints = GetAchievementCategoryInfo(topLevelIndex)
		
		for categoryIndex = 1, numCategories do
			local subcategoryName, numAchievements, earnedSubSubPoints, totalSubSubPoints, hidesSubSubPoints = GetAchievementSubCategoryInfo(topLevelIndex, categoryIndex)
			
			for achievementIndex = 1, numAchievements do
				local achId = GetAchievementId(topLevelIndex, categoryIndex, achievementIndex)
				local currentId = GetFirstAchievementInLine(achId)
				
				if (currentId == 0) then currentId = achId end
								
				while (currentId ~= nil and currentId > 0) do
					local found, total = uespLog.CheckAchievementForSkyshards(currentId)
					totalSkyshards = totalSkyshards + total
					foundSkyshards = foundSkyshards + found
					
					currentId = GetNextAchievementInLine(currentId)
				end				
			end
		end
		
		for achievementIndex = 1, numCateAchievements do
			local achId = GetAchievementId(topLevelIndex, nil, achievementIndex)
			local currentId = GetFirstAchievementInLine(achId)
			
			if (currentId == 0) then currentId = achId end
				
			while (currentId ~= nil and currentId > 0) do
				local found, total = uespLog.CheckAchievementForSkyshards(currentId)
				totalSkyshards = totalSkyshards + total
				foundSkyshards = foundSkyshards + found
				
				currentId = GetNextAchievementInLine(currentId)
			end			
			
		end
	end	
	
		-- Wailing prison
	if (uespLog.CheckAchievementForSkyshards(993)) then
		foundSkyshards = foundSkyshards + 1
	end
	
	return foundSkyshards, totalSkyshards
end


uespLog.CountConstantsTables = {}

function uespLog.CountConstantsInObject(object, origConstants)
	local constants = origConstants or {}
	local k
	local v
	local tableIndex = nil
	
	if (object == nil) then
		return 0
	end
	
	if (origConstants == nil) then
		uespLog.CountConstantsTables = {}
	elseif (uespLog.CountConstantsTables[object]) then
		return 0	-- Already counted
	end
		
	uespLog.CountConstantsTables[object] = 1
	
	repeat
		local status, nextIndex, value = pcall(next, object, tableIndex)
						
		if (nextIndex == nil) then
			break
		end
	
		if (not status) then
			local errIndex = string.match(nextIndex, "Attempt to access a private function '(%w*)' from")
			nextIndex = errIndex
			-- protected/private function
		else
			k = nextIndex
			v = value
			
			local vType = type(v)
			local kType = type(k)
			
			if (kType == "string" or kType == "number" or kType == "boolean") then
				constants[k] = (constants[k] or 0) + 1
			end
			
			if (vType == "number") then
			
					-- NAN check
				if (v ~= v) then
					v = "__NAN__"
				end
				
				constants[v] = (constants[v] or 0) + 1
			elseif (vType == "string" or vType == "boolean") then
				constants[v] = (constants[v] or 0) + 1
			elseif (vType == "table") then
				uespLog.CountConstantsInObject(v, constants)
			end
		end
		
		tableIndex = nextIndex
	until nextIndex == nil
	
	if (origConstants == nil) then
		local count = 0
		
		for k in pairs(constants) do
			count = count + 1
		end
		
		return count
	end
	
	return 0
end


uespLog.CountStringsTables = {}

function uespLog.CountStringsInObject(object, origConstant)
	local constants = 0
	local k
	local v
	local tableIndex = nil
	
	if (object == nil) then
		return 0
	end
	
	if (origConstants == nil) then
		uespLog.CountStringsTables = {}
	elseif (uespLog.CountStringsTables[object]) then
		return 0	-- Already counted
	end
		
	uespLog.CountStringsTables[object] = 1
	
	repeat
		local status, nextIndex, value = pcall(next, object, tableIndex)
						
		if (nextIndex == nil) then
			break
		end
	
		if (not status) then
			local errIndex = string.match(nextIndex, "Attempt to access a private function '(%w*)' from")
			nextIndex = errIndex
			-- protected/private function
		else
			k = nextIndex
			v = value
			
			local vType = type(v)
			local kType = type(k)
			
			if (kType == "string") then
				constants = constants + #k
			end
			
			if (vType == "string") then
				constants = constants + #v
			elseif (vType == "table") then
				constants = constants + uespLog.CountStringsInObject(v, constants)
			end
		end
		
		tableIndex = nextIndex
	until nextIndex == nil
	
	return constants
end


function uespLog.GetMasterWritMotifsKnown()
	local numStyles = GetNumSmithingStyleItems()
	local styleData = uespLog.GetStyleData()
	local totalStyles = 0
	local knownStyles = 0
	
	for i, data in ipairs(styleData) do
		local styleName = data.name
		local itemStyle = data.style
		local known, knownCount = uespLog.GetStyleKnown(styleName)	
		local displayStyle = true
		
		if (uespLog.EXCLUDE_STYLES_MASTERWRIT[itemStyle] == nil) then
			totalStyles = totalStyles + 1
			
			if (knownCount >= 14) then
				knownStyles = knownStyles + 1
			end
		end
	end
	
	if (totalStyles <= 0) then
		return 0
	end
	
	return knownStyles / totalStyles, knownStyles, totalStyles
end


function uespLog.GetAchievementProgressValue(achId)
	local achLink = GetAchievementLink(achId)
	
	if (achLink == nil or achLink == "") then
		return 0, false
	end
	
	local _, progress, timestamp = uespLog.ParseAchievementLinkId(achLink)
	
	return uespLog.CountSetBits(progress), (timestamp > 0)
end


function uespLog.GetProvMasterWritRecipesKnown()
	local recipeCount = 0
	local knownCount = 0
	
	for i, recipeListIndex in ipairs(uespLog.PROV_MASTERWRIT_RECIPELISTS) do
		local listName, numRecipes = GetRecipeListInfo(recipeListIndex)
		
		for recipeIndex = 1, numRecipes do
			local known, name, _, _, quality = GetRecipeInfo(recipeListIndex, recipeIndex)
			local itemLink = GetRecipeResultItemLink(recipeListIndex, recipeIndex)
			local resultQuality = GetItemLinkDisplayQuality(itemLink)
	
			if (name ~= "" and quality >= 3) then
				recipeCount = recipeCount + 1
				
				if (known) then
					knownCount = knownCount + 1
				end
			end
		end
	end
	
	return knownCount / recipeCount, knownCount, recipeCount
end


function uespLog.ShowProvMasterWritRecipes(cmd)
	local recipeCount = 0
	local knownCount = 0
	
	uespLog.MsgColor(uespLog.craftColor, "Recipes contributing to Provisioning Master Writ chance:")
	
	for i, recipeListIndex in ipairs(uespLog.PROV_MASTERWRIT_RECIPELISTS) do
		local listName, numRecipes = GetRecipeListInfo(recipeListIndex)
		
		for recipeIndex = 1, numRecipes do
			local known, name, _, _, quality = GetRecipeInfo(recipeListIndex, recipeIndex)
			local itemLink = GetRecipeResultItemLink(recipeListIndex, recipeIndex)
			local resultQuality = GetItemLinkDisplayQuality(itemLink)
	
			if (name ~= "" and quality >= 3) then
				recipeCount = recipeCount + 1
				
				if (known) then
					knownCount = knownCount + 1
					uespLog.MsgColor(uespLog.craftColor, ".                   "..tostring(itemLink))
				else
					uespLog.MsgColor(uespLog.craftColor, ". (unknown) "..tostring(name))
				end
			end
		end
	end
	
	uespLog.MsgColor(uespLog.craftColor, "You know "..tostring(knownCount).." of "..tostring(recipeCount).." recipes contributing to master writ chance.")
end


function uespLog.ShowMasterWritMotifs(cmd)
	uespLog.StyleCommand("writ")
end


function uespLog.MasterWritCmd(cmd)
	local cmds, firstCmd = uespLog.SplitCommands(cmd)
	
	if (cmd == "prov" or cmd == "provision" or cmd == "provisioning") then
		uespLog.ShowProvMasterWritRecipes(cmds[2])
		return
	elseif (cmd == "motif" or cmd == "motifs" or cmd == "style" or cmd == "styles") then
		uespLog.ShowMasterWritMotifs(cmds[2])
		return
	elseif (cmd == "help") then
		uespLog.Msg("Shows your estimated chance at receiving a master writ for all tradeskills.")
		uespLog.Msg(".      /uespmasterwrit     Shows chances")
		uespLog.Msg(".      /umw                     Short version")
		uespLog.Msg(".      /umw prov             Shows which recipes contribute to chance")
		uespLog.Msg(".      /umw motif            Shows which motifs contribute to chance")
		return
	end
	
	local ChanceRange = uespLog.MASTERWRIT_MAX_CHANCE - uespLog.MASTERWRIT_MIN_CHANCE
	
	local motifChance = uespLog.GetMasterWritMotifsKnown()
	local blackTraits = uespLog.GetCharDataResearchTraits(CRAFTING_TYPE_BLACKSMITHING)
	local jewelTraits = uespLog.GetCharDataResearchTraits(CRAFTING_TYPE_JEWELRYCRAFTING)
	local clothTraits = uespLog.GetCharDataResearchTraits(CRAFTING_TYPE_CLOTHIER)
	local woodTraits = uespLog.GetCharDataResearchTraits(CRAFTING_TYPE_WOODWORKING)
	
	local blackTraitsKnown = blackTraits["Blacksmithing:Trait:Known"] or 0
	local blackTraitsTotal = blackTraits["Blacksmithing:Trait:Total"] or 1
	local clothTraitsKnown = clothTraits["Clothier:Trait:Known"] or 0
	local clothTraitsTotal = clothTraits["Clothier:Trait:Total"] or 1
	local woodTraitsKnown  = woodTraits["Woodworking:Trait:Known"] or 0
	local woodTraitsTotal  = woodTraits["Woodworking:Trait:Total"] or 1
	local jewelTraitsKnown  = jewelTraits["Jewelry:Trait:Known"] or 0
	local jewelTraitsTotal  = jewelTraits["Jewelry:Trait:Total"] or 1
	
	local blackChance = math.floor(uespLog.MASTERWRIT_MIN_CHANCE * 10 + (blackTraitsKnown / blackTraitsTotal + motifChance) * ChanceRange/2 * 10 + 0.5) / 10
	local clothChance = math.floor(uespLog.MASTERWRIT_MIN_CHANCE * 10 + (clothTraitsKnown / clothTraitsTotal + motifChance) * ChanceRange/2 * 10 + 0.5) / 10
	local woodChance  = math.floor(uespLog.MASTERWRIT_MIN_CHANCE * 10 + (woodTraitsKnown  / woodTraitsTotal  + motifChance) * ChanceRange/2 * 10 + 0.5) / 10
	local jewelChance  = math.floor(uespLog.MASTERWRIT_MIN_CHANCE * 10 + (jewelTraitsKnown  / jewelTraitsTotal) * ChanceRange * 10 + 0.5) / 10
		
	local runesKnown = 0
	runesKnown = runesKnown + uespLog.GetAchievementProgressValue(781)
	runesKnown = runesKnown + uespLog.GetAchievementProgressValue(788)
	runesKnown = runesKnown + uespLog.GetAchievementProgressValue(779)
	runesKnown = runesKnown + uespLog.GetAchievementProgressValue(780)
	runesKnown = runesKnown + uespLog.GetAchievementProgressValue(1317)
	
	local reagentsKnown = 0
	reagentsKnown = reagentsKnown + uespLog.GetAchievementProgressValue(1045)
	reagentsKnown = reagentsKnown + uespLog.GetAchievementProgressValue(1464)
		
	local recipesKnown = uespLog.GetProvMasterWritRecipesKnown()
	
	local alchemyChance = math.floor(uespLog.MASTERWRIT_MIN_CHANCE * 10 + reagentsKnown / (18 + 8) * ChanceRange * 10 + 0.5) / 10
	local enchantChance = math.floor(uespLog.MASTERWRIT_MIN_CHANCE * 10 + runesKnown / (5 + 17 + 14 + 14 + 5) * ChanceRange * 10 + 0.5) / 10
	local provChance    = math.floor(uespLog.MASTERWRIT_MIN_CHANCE * 10 + recipesKnown * ChanceRange * 10 + 0.5) / 10
		
	uespLog.MsgColor(uespLog.craftColor, "Estimated Chance to Receive a Master Writ:")
	uespLog.MsgColor(uespLog.craftColor, ".   Alchemy: "..tostring(alchemyChance).. "%")
	uespLog.MsgColor(uespLog.craftColor, ".   Blacksmithing: "..tostring(blackChance).. "%")
	uespLog.MsgColor(uespLog.craftColor, ".   Clothing: "..tostring(clothChance).. "%")
	uespLog.MsgColor(uespLog.craftColor, ".   Enchanting: "..tostring(enchantChance).. "%")
	uespLog.MsgColor(uespLog.craftColor, ".   Jewelry: "..tostring(jewelChance).. "%")
	uespLog.MsgColor(uespLog.craftColor, ".   Provisioning: "..tostring(provChance).. "%")
	uespLog.MsgColor(uespLog.craftColor, ".   Woodworking: "..tostring(woodChance).. "%")
end


SLASH_COMMANDS["/uespmasterwrit"] = uespLog.MasterWritCmd



function uespLog.MakePotionLink(effectIndex)
	local itemLink = uespLog.MakeItemLinkEx( { itemId = 54339, level = 1, quality = 123, potionEffect = effectIndex } )
	uespLog.Msg("Potion #" .. tostring(effectIndex)..":" .. tostring(itemLink))
end


function uespLog.TestSkillDesc(abilityId, maxCount)
	local i
	
	maxCount = maxCount or 20000
	abilityId = abilityId or 20328
	
	local firstDesc = GetAbilityDescription(abilityId, 1)
	--local desc
	
	d("Testing description of ability "..tostring(abilityId).." with "..tostring(#firstDesc).." characters...")
	
	for i = 1, maxCount do
		local desc = GetAbilityDescription(abilityId, 1)
		
		if (desc ~= firstDesc) then
			d(""..tostring(i)..") Description mismatch")
			d("Orig Desc:"..tostring(firstDesc))
			d("Last Desc:"..tostring(desc))
			return false
		end
	end
	
	return true
end


function uespLog.MarketCommand(cmd)
	local cmds, firstCmd = uespLog.SplitCommands(cmd)

	if (firstCmd == "on") then
		uespLog.SetCloseMarketAnnouncement(false)
		uespLog.Msg("The market announcement will now be displayed when you login.")
	elseif (firstCmd == "off") then
		uespLog.SetCloseMarketAnnouncement(true)
		uespLog.Msg("The market announcement will *not* be displayed when you login.")
	else
		uespLog.Msg("Turns the game's market announcement window on/off:")
		uespLog.Msg(".     /uespmarket [on||off]")
	
		if (uespLog.GetCloseMarketAnnouncement()) then
			uespLog.Msg("The market announcement will *not* be displayed when you login.")
		else
			uespLog.Msg("The market announcement will be displayed when you login.")
		end
	end
	
end


--SLASH_COMMANDS["/uespmarket"] = uespLog.MarketCommand


uespLog.MINEANTIQUITY_MINID = 0
uespLog.MINEANTIQUITY_MAXID = 2000
uespLog.MineAntiquitySetData = {}
uespLog.MineAntiquityCategoryData = {}


function uespLog.CreateAntiquitySetData()
	uespLog.MineAntiquitySetData = {}
	uespLog.MineAntiquityCategoryData = {}
	
	for antiquityId = uespLog.MINEANTIQUITY_MINID, uespLog.MINEANTIQUITY_MAXID do
		local name = GetAntiquityName(antiquityId)
	
		if (name ~= nil and name ~= "") then
			local setId = GetAntiquitySetId(antiquityId)
			local categoryId = GetAntiquityCategoryId(antiquityId)
			
			if (setId and setId > 0) then
				if (uespLog.MineAntiquitySetData[setId] == nil) then
					uespLog.MineAntiquitySetData[setId] = {}
					uespLog.MineAntiquitySetData[setId].count = 0
				end
				
				uespLog.MineAntiquitySetData[setId].count = uespLog.MineAntiquitySetData[setId].count + 1
			end
			
			if (categoryId and categoryId > 0) then
				if (uespLog.MineAntiquityCategoryData[categoryId] == nil) then
					uespLog.MineAntiquityCategoryData[categoryId] = {}
					uespLog.MineAntiquityCategoryData[categoryId].count = 0
				end
				
				uespLog.MineAntiquityCategoryData[categoryId].count = uespLog.MineAntiquityCategoryData[categoryId].count + 1
			end
			
		end
		
	end
end


function uespLog.MineAntiquities() 
	local validCount = 0
	local antiquityId
	local logData = {}
	
	uespLog.Msg("Starting to mine antiquities from "..uespLog.MINEANTIQUITY_MINID.." to "..uespLog.MINEANTIQUITY_MAXID.."...")
	
	logData.event = "mineanti::start"
	uespLog.AppendDataToLog("all", logData, uespLog.GetTimeData())
		
	uespLog.CreateAntiquitySetData()

	for antiquityId = uespLog.MINEANTIQUITY_MINID, uespLog.MINEANTIQUITY_MAXID do
		local result = uespLog.MineAntiquity(antiquityId)
		
		if (result) then
			validCount = validCount + 1
		end
	end
	
	logData.event = "mineanti::end"
	uespLog.AppendDataToLog("all", logData, uespLog.GetTimeData())
	
	uespLog.Msg("Finished mining antiquities...found "..validCount.." valid antiquities!")
	
end


function uespLog.MineAntiquity(antiquityId) 
	local logData = {}
	
	logData.name = GetAntiquityName(antiquityId)
	
	if (logData.name == nil or logData.name == "") then
		return false
	end
	
	logData.event = "mineanti"
	logData.id = antiquityId
    logData.requiresLead = DoesAntiquityRequireLead(antiquityId)
    logData.icon = GetAntiquityIcon(antiquityId)
    logData.quality = GetAntiquityQuality(antiquityId)
    logData.rewardId = GetAntiquityRewardId(antiquityId)
    logData.isRepeatable = IsAntiquityRepeatable(antiquityId)
    logData.zoneId = GetAntiquityZoneId(antiquityId)
    logData.difficulty = GetAntiquityDifficulty(antiquityId)
	
	logData.setId = GetAntiquitySetId(antiquityId)
		
	if (logData.setId and logData.setId ~= 0) then
		local setData = uespLog.MineAntiquitySetData[logData.setId]
		
		logData.setCount = setData.count
		logData.setName = GetAntiquitySetName(logData.setId)
		logData.setIcon = GetAntiquitySetIcon(logData.setId)
		logData.setQuality = GetAntiquitySetQuality(logData.setId)
		logData.setRewardId = GetAntiquitySetRewardId(logData.setId)
    end
	
	logData.categoryId = GetAntiquityCategoryId(antiquityId)
	
    if (logData.categoryId and logData.categoryId ~= ZO_SCRYABLE_ANTIQUITY_CATEGORY_ID) then
		local categoryData = uespLog.MineAntiquityCategoryData[logData.categoryId]
		
		logData.categoryCount = categoryData.count
		logData.categoryOrder = GetAntiquityCategoryOrder(logData.categoryId)
		logData.categoryName = GetAntiquityCategoryName(logData.categoryId)
		logData.cateNormalIcon, logData.catePressedIcon, logData.cateMousedOverIcon = GetAntiquityCategoryKeyboardIcons(logData.categoryId)
		logData.parentCategoryId = GetAntiquityCategoryParentId(logData.categoryId)
    end
	
	logData.numLoreEntries = GetNumAntiquityLoreEntries(antiquityId)
	
	for loreEntryIndex = 1, logData.numLoreEntries do
        local loreDisplayName, loreDescription = GetAntiquityLoreEntry(antiquityId, loreEntryIndex)
		
		logData["loreName" .. loreEntryIndex] = loreDisplayName
		logData["loreDesc" .. loreEntryIndex] = loreDescription
    end
	
	uespLog.AppendDataToLog("all", logData)
	
	return true
end


function uespLog.LogLocationData()
	local logData = {}
	
	logData.event = "loglocation"
	
	logData.zoneName = GetPlayerActiveZoneName()
	logData.subzoneName = GetPlayerActiveSubzoneName()
	logData.zoneIndex = GetCurrentMapZoneIndex()
	logData.zoneDesc = GetZoneDescription(logData.zoneIndex)
	logData.zoneId = GetZoneId(logData.zoneIndex)
	
	uespLog.DebugExtraMsg("UESP LogLocationData: "..tostring(logData.zoneName)..":"..tostring(logData.subzoneName).." ("..tostring(logData.zoneIndex)..":"..tostring(logData.zoneId)..")")
	
	logData.mapName = GetMapName()
	logData.mapType = GetMapType()
	logData.mapContentType = GetMapContentType()
	logData.mapFilterType = GetMapFilterType()
	
	logData.allowsScaling = DoesCurrentZoneAllowScalingByLevel()
	logData.allowsBattleScaling = DoesCurrentZoneAllowBattleLevelScaling()
	logData.scaleLevelConstraint, logData.minLevel, logData.maxLevel = GetCurrentZoneLevelScalingConstraints()
	
	logData.isAvA1 = IsInAvAZone()
	logData.isAvA2 = IsPlayerInAvAWorld()
	logData.isBattleground = IsActiveWorldBattleground()
	logData.telvarBehavior = DoesCurrentZoneHaveTelvarStoneBehavior()
	logData.isOutlaw = IsInOutlawZone()
	logData.isJustice = IsInJusticeEnabledZone()
	logData.isTutorial = IsInTutorialZone()
	logData.isGroupOwnable = IsActiveWorldGroupOwnable()
	logData.isDungeon = IsUnitInDungeon("player")
	logData.dungeonDifficulty = GetCurrentZoneDungeonDifficulty()
	
	logData.numPOIs = GetNumPOIs(logData.zoneIndex)
	
	logData.subZoneIndex, logData.poiIndex = GetCurrentSubZonePOIIndices()
	logData.normX, logData.normZ, logData.poiPinType, logData.mapIcon, logData.isShown, _ = GetPOIMapInfo(logData.zoneIndex, logData.poiIndex)
	logData.poiType = GetPOIType(logData.zoneIndex, logData.poiIndex)
	
	uespLog.DebugExtraMsg("UESP LogLocationData: POIs "..tostring(logData.numPOIs)..": "..tostring(logData.zoneIndex)..":"..tostring(logData.poiIndex)..":"..tostring(logData.poiType).."")
	
	logData.objectiveName, logData.objectiveLevel, logData.startDesc, logData.endDesc = GetPOIInfo(logData.zoneIndex, logData.poiIndex)
	
	uespLog.AppendDataToLog("all", logData, uespLog.GetTimeData())
end


uespLog.MINETEST_RELOAD_COUNT = 150
uespLog.mineTestCount = 0
uespLog.mineTestStop = false
uespLog.MINETEST_AUTOSTARTNEXT = false


function uespLog.StartMineTest(startIndex, autoStart)
	uespLog.MINETEST_AUTOSTARTNEXT = autoStart or false
	uespLog.mineTestCount = 0
	uespLog.mineTestStop = false
	uespLog.NextMineTestIndex = startIndex or 1
	uespLog.savedVars.settings.data.mineTestIndex = uespLog.NextMineTestIndex
	uespLog.savedVars.settings.data.mineTestAutoStart = uespLog.MINETEST_AUTOSTARTNEXT
	
	uespLog.Msg("Starting Auto-Mine Test at "..tostring(uespLog.NextMineTestIndex).."...")
	
	uespLog.MineItemsOutputStartLog()
	
	zo_callLater(uespLog.DoNextMineTest, 2000)	
end


function uespLog.StopMineTest()
	uespLog.savedVars.settings.data.mineTestIndex = nil
	uespLog.mineTestStop = true
	uespLog.MineItemsOutputEndLog()
end


function uespLog.ResumeMineTest()

	--uespLog.LoadBackupTraits()
	
	uespLog.ClearSavedVarSection("all")
	uespLog.NextMineTestIndex = uespLog.savedVars.settings.data.mineTestIndex
	uespLog.MINETEST_AUTOSTARTNEXT = uespLog.savedVars.settings.data.mineTestAutoStart or false
	uespLog.mineTestCount = 0
	uespLog.Msg("Resuming Auto-Mine Test at "..tostring(uespLog.NextMineTestIndex).."...")
	
	uespLog.MineItemsOutputStartLog()
	
	zo_callLater(uespLog.DoNextMineTest, 4000)
end


function uespLog.StartNextMineTest()
	zo_callLater(uespLog.DoNextMineTest, 3000)
end


function uespLog.DoNextMineTest()

	if (uespLog.mineTestStop or uespLog.NextMineTestIndex == nil) then
		return
	end
		
	local funcName = "uespminetest" .. uespLog.NextMineTestIndex
	
	if (_G[funcName] == nil) then
		uespLog.Msg("Stopped at MineTest index " .. uespLog.NextMineTestIndex .. "!")
		uespLog.MineItemsOutputEndLog()
		uespLog.savedVars.settings.data.mineTestIndex = nil
		return 
	end
	
	uespLog.Msg("Running MineTest index " .. uespLog.NextMineTestIndex .. "...")
	
	_G[funcName]()
	
	uespLog.mineTestCount = uespLog.mineTestCount + 1
	uespLog.NextMineTestIndex = uespLog.NextMineTestIndex + 1
	uespLog.savedVars.settings.data.mineTestIndex = uespLog.NextMineTestIndex
	
	if (uespLog.mineTestCount >= uespLog.MINETEST_RELOAD_COUNT) then
		uespLog.Msg("Auto-reloading...")
		uespLog.MineItemsOutputEndLog()
		SLASH_COMMANDS["/reloadui"]()
		return
	end
	
	if (uespLog.MINETEST_AUTOSTARTNEXT) then
		zo_callLater(uespLog.DoNextMineTest, 2000)
	end
end


--uespLog.MineSingleItemSafe_FinishCallback = uespLog.StartNextMineTest


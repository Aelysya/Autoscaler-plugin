# Autoscaler-Plugin

This plugin allows you to automatically scale the encounters you set up in your fangame depending on various configuration options, like taking into account evolutions, movesets, and the context of the encounter.

## Useful links

- [Discord server](https://discord.gg/0noB0gBDd91B8pMk)

## How to install

To install this plugin in your project, follow these steps:

- Download the latest release from the repository.
- Unzip the archive, you should find a file called `Autoscaler.psdkplug`.
- Copy this file in the `scripts` folder that is located at the root of your project.
- Go back to your project's root folder, and run the `cmd.bat` executable, a console should open up.
- Enter the command `psdk --util=plugin load` to install the plugin.
- That's it!

## How to update

In the event of an update of the plugin, here are the steps to follow if you already have it installed in your project:

- Download the latest release from the repository.
- Unzip the archive.
- Replace the `Autoscaler.psdkplug` file located in your `scripts` folder with the one you downloaded.
- Go back to your project's root folder and run the `cmd.bat` executable, a terminal should open up.
- Enter the command `psdk --util=plugin load` to update the plugin.

## Configuration

Now that the plugin is installed, you'll need to configure it, and there's a lot to talk about.
The configuration file you are looking for is named `autoscaler_config.json` and is located in the `Data/configs` folder of your project.

There are 13 switches and 4 variables brought with this plugin, they are mapped to default values when you install the plugin for the first time. Since these numbers may conflict with some of your own, feel free to re-map them all to free spaces. To do that, you just have to change the number associated with them in the configuration file.

### Global activation

The `globalActivationSwitch` switch is pretty straightforward, activating it makes the plugin able to scale the levels of the encounters. This is the master switch, when it's **OFF**, the plugin is **OFF**.
The real use of this will most likely be to turn it **OFF** when you want to deactivate everything momentarily for an encounter to not be scaled, that way you don't have to modify anything else.

### Context-dependant activation

You may want to allow the plugin to scale the Wild Pokémon, but not the trainers. There are 4 switches that allow you to choose in which context the autoscaler will work or not:

- The `allowTrainersScalingSwitch` switch allows scaling the enemy trainers.
- The `allowAllyTrainersScalingSwitch` switch allows scaling the ally trainers.
- The `allowWildBattlesScalingSwitch` switch allows scaling the wild battles.
- The `allowQuestRewardsScalingSwitch` switch allows scaling the quest rewards (eggs will not be scaled, for obvious reasons).

To activate the autoscaler for any of these contexts, set it's related switch **ON**.

### Level scaling

All the things the plugin does are linked to level scaling, here are the information you need to configure how it will be done.

There is no specific switch to activate the level scaling, the **global switch** does that.
You may also want to allow the plugin to scale down the encounters' level, you can set the `allowLevelScalingDownSwitch` **ON** for that.

#### Scaling reference

The scaling reference is the value the plugin will scale the encounters levels towards.
There are 4 modes you can use:

- (0) Average, the scaling reference will be the average level of the team.
- (1) Party highest, the scaling reference will be the highest level in the team.
- (2) Overall highest, the scaling reference will be the highest level amongst the team and the Pokémon in the PC boxes.
- (3) Manual target, the scaling reference will be the value contained in the `manualTargetLevelVariable` variable.

Noticed the number between parentheses? This is the value you will need to set in the `scalingModeVariable` variable to choose the scaling mode you want to use.
Once the scaling reference is calculated, you can modify it using the `flatLevelModifierVariable` variable, the value contained will be added to the scaling reference (it can be negative).

#### Scaling limitation

You can limit how much the level an encounter can change by using the `maximumLevelsToScaleVariable` variable. This will make it so, if the scaling reference is greater than this maximum, the final level of an encounter change the maximum's value rather than all the way to the reference. If you set it to 100 (or the maximum level of your fangame) there will be no limit to the level change of any encounter.

#### Practical examples (Level)

##### Example 1

The setup:

- The encounter is set to be a level 10 Zubat in Pokémon Studio.
- The global and wild scaling switches are **ON**.
- The scaling reference mode is **Manual** (Mode 3), the target is set to 50, with a flat modifier of 10 and a change limit of 100.

What happens: The autoscaler will try to scale the Zubat's level to the manual target of 50, adding the flat modifier it gives a final target level of 60. Since it's only 50 levels away from the base level it can be fully scaled and will be level 60 when the battle starts.

##### Example 2

The setup:

- The encounter is set to be a level 10 Zubat in Pokémon Studio.
- The global and wild scaling switches are **ON**.
- The scaling reference mode is **Manual** (Mode 3), the target is set to 50, with a flat modifier of 10 and a change limit of 10.

What happens: The autoscaler will try to scale the Zubat's level to the manual target of 50, adding the flat modifier it gives a final target level of 60. Since it's 50 levels away from the base level it cannot be fully scaled and will only be level 20 when the battle starts.

##### Example 3

The setup:

- The encounter is set to be a level 60 Zubat in Pokémon Studio.
- The global, wild scaling and level scaling down switches are **ON**.
- The scaling reference mode is **Manual** (Mode 3), the target is set to 40, with a flat modifier of 10 and a change limit of 100.

What happens: The autoscaler will try to scale the Zubat's level to the manual target of 40, adding the flat modifier it gives a final target level of 50. Since it's only 10 levels away from the base level it can be fully scaled and will be level 50 when the battle starts.

##### Example 4

The setup:

- The encounter is set to be a level 60 Zubat in Pokémon Studio.
- The global switch and wild scaling switches are **ON**.
- The level scaling down switch is **OFF**.
- The scaling reference mode is **Manual** (Mode 3), the target is set to 40, with a flat modifier of 10 and a change limit of 100.

What happens: The autoscaler will try to scale the Zubat's level to the manual target of 40, adding the flat modifier it gives a final target level of 50. Since the target is lower than the starting level and the level  scaling down switch is **OFF**, the Zubat will stay at level 60 when the battle starts.

### Evolution scaling

Scaling the level is nice, but if you end up fighting a level 80 Bidoof that could be strange (or that also could be what you want, no judgment here).
By setting the `allowEvolutionScalingSwitch` **ON**, you will allow the plugin the evolve the encounters if they have a high enough level. Similarly, you can allow encounters to de-evolve by setting the `allowEvolutionScalingDownSwitch` **ON**.

Note: An overleveled, low stage Pokémon will not evolve if it's level is reduced to a value that is still above it's evolution level. The opposite is also true.
Examples:

- A level 50 Bulbasaur scaled down to level 40 will not evolve all the way to a Venusaur despite being over level 32, it will stay as a Bulbasaur.
- A level 5 Venusaur scaled up to level 10 will not de-evolve all the way to a Bulbasaur despite being under level 16, it will stay as a Venusaur.

#### Non-Level up evolution methods

Level based evolutions do not need any additional modifications, but other methods will need you to give a specific level at which the condition is considered fullfilled.
The configuration file contains an array named `evolutionLevelsForSpecificMethods`, this array contains a series of arrays, one for each evolution method. Each of these arrays contain 2 values, these will be the levels at which the Pokémon can be evolved into their next stage. The first value is for stage 0 Pokémon to evolve into stage 1, the second value is for stage 1 Pokémon to evolve into stage 2. These values will be used globally, so each stage 1 Pokémon that evolve using a stone will use the second value of the `stone` array. If you want to configure exceptions and make only one precise Pokémon evolve at a certain level, see the next part.

Special cases:

- "Minimum Loyalty" and "Maximum Loyalty" based evolutions are grouped in the `loyalty` array.
- "Trade" and "Trade With" based evolutions are grouped in the `trade` array.
- "Skill" based evolutions are grouped in the `skill` array (there are 4 different skill-based conditions in PSDK).

#### Custom evolutions checking

You may want to make evolve some species at a certain level, whether it is to more finely tune the non-level based evolutions described above, or to make some species evolve later than they should ordinarily do.
To do that, you use the `customEvolutionChecks` array in the configuration file. Following the examples that are already in the file, you can create new sub-arrays containing the symbol of the Pokémon in first position, and the level it will be evolving into it's next stage in second position.
Important note: If a species is contained in this array, it will be the only condition checked for evolution, any other existing conditions will not be verified.

#### Multiple evolutions handling

In case a Pokémon has multiple possible evolutions at the same time, you can use the `multipleEvolutionsChoiceMode` parameter to tell the plugin how to choose between the possibilities. The possible values for this parameter are `random`, `first` and `last`. Evolutions are ordered the way they are seen in Pokémon Studio.

Practical tip: Since this can be quite limiting, I have a tip for you if you want to force a specific evolution to be chosen. You can do that by setting up the encounter to be the evolution you want to force, set it's level to be the one needed to evolve, and set the evolution scaling down switch **ON**. That way, you'll always have the correct evolution is case it's level is unchanged or up-scaled, but if it's downscaled it will de-evolve correctly (since there are no converging evolution lines)

#### Practical examples (evolution)

##### Example 5

The setup:

- The encounter is set to be a level 10 Bulbasaur in Pokémon Studio.
- The global, wild scaling and evolution scaling switches are **ON**.
- Assume the scaling will bring the Bulbasaur to level 50.

What happens: Bulbasaur will evolve into Ivysaur at level 16, and Ivysaur will evolve into Venusaur at level 32. The encounter will be a level 50 Venusaur when the battle starts.

##### Example 6

The setup:

- The encounter is set to be a level 10 Bellsprout in Pokémon Studio.
- The global, wild scaling and evolution scaling switches are **ON**.
- The evolution levels setup for `stone` based evolutions is [15, 30].
- Assume the scaling will bring the Bellsprout to level 25.

What happens: Bellsprout will evolve into a Weepinbell because it is above level 21, but not into a Victreebel since the evolution level for stage 1 Pokémon using a stone is set to 30. The encounter will be a level 25 Weepinbell when the battle starts.

##### Example 7

The setup:

- The encounter is set to be a level 10 Vulpix in Pokémon Studio.
- The global, wild scaling and evolution scaling switches are **ON**.
- The evolution levels setup for `stone` based evolutions is [15, 30].
- Assume the scaling will bring the Vulpix to level 25.

What happens: Vulpix will evolve into Ninetales since the evolution level for stage 0 Pokémon using a stone is set to 15. The encounter will be a level 25 Ninetales when the battle starts.

##### Example 8

The setup:

- The encounter is set to be a level 10 Geodude in Pokémon Studio.
- The global, wild scaling and evolution scaling switches are **ON**.
- The evolution levels setup for `trade` based evolutions is [15, 30].
- A custom evolution check is set for Graveler ['graveler', '26'].
- Assume the scaling will bring the Geodude to level 28.

What happens: Geodude will evolve into Graveler at level 25, and Graveler will evolve into Golem despite the evolution level for stage 1 Pokémon by trade being set to 30 because there is a custom check that takes priority set to level 26. The encounter will be a level 28 Golem when the battle starts.

##### Example 9

The setup:

- The encounter is set to be a level 10 Machop in Pokémon Studio.
- The global, wild scaling and evolution scaling switches are **ON**.
- The evolution levels setup for `trade` based evolutions is [15, 30].
- A custom evolution check is set for Machoke ['machoke', '40'].
- Assume the scaling will bring the Machop to level 35.

What happens: Machop will evolve into Machoke at level 28, but not in a Machamp despite the evolution level for stage 1 Pokémon by trade being set to 30 because there is a custom check that takes priority set to level 40. The encounter will be a level 35 Machoke when the battle starts.

### Moveset scaling

This plugin can also scale the movesets of the encounters, while this functionnality will rarely have a use for wild battles (since it is the default behaviour of PSDK), it might have one for the trainers and quest rewards.
Setting the `allowMovesetScalingSwitch` **ON**, you will allow the plugin the modify the encounters's moveset if they have a high enough level after it has itself been scaled. Similarly, you can allow encounters to receive a weaker moveset using the `allowMovesetScalingDownSwitch` set to **ON**.

#### Move replacing options

There are 3 switches used to define which moves you want to allow replacing in a moveset:

- The `allowNonLevelUpMovesReplacingSwitch` switch allows the plugin to replace the moves an encounter cannot learn by level-up (TM/HM, egg, tutor, evolution, custom), this basically means you allow the autoscaler to override some design choices you may have made for your encounter (like giving Flamethrower to a Bulbasaur). If you don't want the plugin to replace intentional design choices, leave this switch **OFF**.
- The `allowDifferentTypeMovesReplacingSwitch` switch makes it so if an offensive move would be replaced, the replacement is limited to be of the same type, the same category, and if multiple moves are possible, select the one with the highest power. In case there are no replacements found, the move is untouched. If you want to force the plugin to limit the type and category changes, leave this switch **OFF**.
- The `allowStatusMovesReplacingSwitch` switch allows the plugin to replace status moves. These kind of moves are generally unique, so you may have set them on an encounter for a reason and will likely not want it to be replaced. If you don't want the plugin to replace your chosen status moves, leave this switch **OFF**.

During the process of moveset scaling, if a move is to be replaced, it will behave like you set it to "By default" in Pokémon Studio, meaning it will be replaced by the last available move learned by level-up.

Notes: moves set to be "None" in Pokémon Studio will not be modified, the final encounter will keep the amount of moves you chose.

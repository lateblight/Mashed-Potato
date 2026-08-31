# Mashed Potato

A Dalamud plugin for FFXIV that swaps Lalafell character models into a different race of your choice directly on your screen.

## Why this exists
I put this together for players who want a more comfortable visual experience. FFXIV is a massive social game, and player outfits can sometimes get pretty revealing. For some of us, seeing the child-like Lalafell models in those types of outfits is just uncomfortable to look at. 

Mashed Potato basically works like a local visual filter. It changes absolutely nothing for anyone else on the server. It simply intercepts the character data as it loads onto your screen and swaps Lalafells to standard adult-proportioned races, so you can just relax and play the game.

**Requirement:** You need to have [Penumbra](https://github.com/xivdev/Penumbra) installed and active for this to work, as it handles the actual model redrawing.

## How to install and use it
1. Open your Dalamud Settings in-game by typing `/xlsettings` in the chat.
2. Go to the Experimental tab.
3. Copy and paste the following link into a blank box under Custom Plugin Repositories to add Penumbra: `https://raw.githubusercontent.com/xivdev/Penumbra/master/repo.json`
4. Click the + button.
5. In the next blank box, paste the link for Mashed Potato: `https://raw.githubusercontent.com/Lateblight/Mashed-Potato/main/repo.json`
6. Click the + button again, then click "Save and Close".
7. Open the Dalamud Plugin Installer (`/xlplugins`), find both Penumbra and Mashed Potato in the Available Plugins tab, and install them.
8. Type `/mash` in the game chat to open the configuration menu and pick the race you want to see instead[cite: 1]. You can also type `/mash on` or `/mash off` to quickly enable or disable the filter without opening the menu[cite: 1].

## The Legal Stuff

### Terms of Service
Square Enix strictly prohibits the use of third-party tools in their Terms of Service. This is a client-side only mod. It does not touch the game servers, modify permanent game files, or give you any sort of gameplay advantage. However, you are using it entirely at your own risk. I am not responsible for any account penalties. Please be smart and do not talk about using mods in the in-game chat.

### License & Copyright
This project is open-source under the MIT License. You are free to view, modify, and share the code, as long as you keep the original license and copyright notices intact. This plugin is completely unofficial and not affiliated with Square Enix.

## Credits
This project was forked and modified by Lateblight. 

A massive thank you to the original OopsAllLalafellsSRE developers who did the foundational coding for this tool:
* Avaflow (Original Creator)
* Ars Magna (Updates)
* Kelvin (Updates)

## Search Tags
FFXIV, Final Fantasy XIV, Dalamud Plugin, Penumbra, Lalafell Model Swap, Race Swap, Visual Filter, FFXIV Modding, OopsAllLalafells, Mashed-Potato, SRE, Lalafells, lala

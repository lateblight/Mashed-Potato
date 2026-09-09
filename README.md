# Mashed Potato 🥔
[![Automated Build](https://github.com/Lateblight/Mashed-Potato/actions/workflows/build.yml/badge.svg)](https://github.com/Lateblight/Mashed-Potato/actions/workflows/build.yml)

A lightweight, client-side Dalamud plugin for *Final Fantasy XIV* that politely intercepts character data and swaps Lalafell models into a proper, grown-up race of your choice directly on your screen.

---

## 🧐 Why This Exists
Let's be completely honest: the broader modding culture surrounding certain player models in *Final Fantasy XIV* can occasionally cross lines into deeply uncomfortable territory. Between overly revealing custom glamours and the prevalence of illicit, highly disturbing modifications used by others in public spaces, seeing those child-like Lalafell models caught in the middle of it can ruin the immersion—and peace of mind—of normal gameplay. 

**Mashed Potato** was built as a firm boundary for your own screen. It modifies absolute zero on the server side—nobody else can see what you've done, and it gives you zero unfair advantages. It simply catches the character data as it loads onto your machine, filters out the models you'd rather not look at by giving the ankle-biters a sensible altitude adjustment, and lets you get on with your dungeon crawling in peace.

> **Requirement:** You must have [Penumbra](https://github.com/xivdev/Penumbra) installed and active for this to work, as it handles the heavy lifting of the actual model redrawing under the hood.

---

## ⚙️ How to Install & Use It

1. Open your Dalamud settings in-game by typing `/xlsettings` in your chat.
2. Navigate over to the **Experimental** tab.
3. Paste the following repository link into a blank box under **Custom Plugin Repositories** to add Penumbra:  
   `https://raw.githubusercontent.com/xivdev/Penumbra/master/repo.json`
4. Click the **`+`** button.
5. In the next blank box down, paste the link for Mashed Potato:  
   `https://raw.githubusercontent.com/Lateblight/Mashed-Potato/main/repo.json`
6. Click **`+`** again, then hit **Save and Close**.
7. Open the Dalamud Plugin Installer (`/xlplugins`), find both Penumbra and Mashed Potato in the *Available Plugins* tab, and click install.
8. Type `/mash` in chat to open the configuration menu and choose your preferred target race. You can also type `/mash on` or `/mash off` to quickly toggle the filter on the fly.

### 🛡️ The Whitelist Feature (For Trusted Friends)
We know that not *all* Lalafells are problematic—you might have close friends who play them normally and whom you want to see in their original form. 

To handle this, Mashed Potato features a robust whitelist:
* Simply right-click a trusted player in the game world, your party list, or chat.
* Select the **Add to Mashed Potato Whitelist** option from the context menu.
* They will be completely exempted from the fryer, allowing them to remain safely as a Lalafell exclusively on your screen while everyone else gets mashed.

---

## ⚖️ The Legal & Boring Bit

### Terms of Service
Square Enix strictly prohibits the use of third-party memory-injection tools in their Terms of Service. This is a purely client-side visual mod. It does not touch game servers, alter permanent game files, or grant gameplay advantages. However, **you use this entirely at your own risk**. I take zero responsibility for account penalties. Be sensible—don't go rabbiting on about mods in public chat channels.

### License & Copyright
This project is open-source under the MIT License. You are free to view, fork, modify, and share the code, provided you keep the original copyright and license notices intact. This plugin is entirely unofficial and has no affiliation with Square Enix.

---

## 🛠️ Credits & Acknowledgements
Modernised, maintained, and packed with automated pipelines by **Lateblight**. 

A massive nod of appreciation to the original *OopsAllLalafells* developers who laid down the foundational codebase:
* **Avaflow** (Original Creator)
* **Ars Magna** (Updates)
* **Kelvin** (Updates)

## Search Tags
FFXIV, Final Fantasy XIV, Dalamud Plugin, Penumbra, Lalafell Model Swap, Race Swap, Visual Filter, FFXIV Modding, OopsAllLalafells, Mashed-Potato, SRE, Lalafells, lalaSSS
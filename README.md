# Mashed Potato 🥔

[![Automated Build](https://github.com/Lateblight/Mashed-Potato/actions/workflows/build.yml/badge.svg)](https://github.com/Lateblight/Mashed-Potato/actions/workflows/build.yml)

A lightweight, client-side Dalamud plugin for *Final Fantasy XIV* that politely intercepts character data and swaps Lalafell models into a proper, grown-up race of your choice directly on your screen.

---

## 🧐 Purpose & Philosophy
Let's be completely honest: the broader modding culture surrounding certain player models in *Final Fantasy XIV* can occasionally cross lines into deeply uncomfortable territory. **Mashed Potato** was built as a firm boundary for your own screen. 

It modifies absolute zero on the server side—nobody else can see what you have done, and it gives you zero unfair advantages. It simply catches the character data as it loads onto your machine, filters out the models you would rather not look at by giving the ankle-biters a sensible altitude adjustment, and lets you get on with your dungeon crawling in peace.

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

* **Configuration:** Type `/mash` in chat to open the configuration menu and choose your preferred target race. 
* **Quick Toggles:** You can also type `/mash on` or `/mash off` to quickly toggle the filter on the fly.

### 🛡️ The Whitelist Feature (For Trusted Friends)
We know that not *all* Lalafells are problematic—you might have close friends who play them normally and whom you want to see in their original form. Mashed Potato features a robust, zero-flicker whitelist:
* Simply right-click a trusted player in the game world, your party list, or chat.
* Select the **Add to Mashed Potato Whitelist** option from the context menu.
* They will be completely exempted from the filter, allowing them to remain safely as a Lalafell exclusively on your screen while everyone else gets mashed.

---

## ⚖️ License & Legal

**Terms of Service Notice:** 
Square Enix strictly prohibits the use of third-party memory-injection tools in their Terms of Service. This is a purely client-side visual mod. It does not touch game servers, alter permanent game files, or grant gameplay advantages. However, **you use this entirely at your own risk**. The developers take zero responsibility for account penalties. Be sensible—do not discuss mods in public chat channels.

**MIT License**
Copyright (c) 2026 Lateblight
*Original Codebase Copyright (c) 2021 Ava Ryan*

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

---

## 🛠️ Credits & Independence
Mashed Potato has been fundamentally rewritten, modernised, and detached into a completely independent project by **Lateblight** (optimised for Dalamud API 15). 

A massive nod of appreciation to the original *OopsAllLalafells* developers who laid down the foundational codebase that this project was originally forked from:
* **Avaflow** (Original Creator)
* **Ars Magna** (Updates)
* **Kelvin** (Updates)

# PAYDAY 2 Mods

A bundle of PAYDAY 2 mods ready to drop into your game. Installation is just a
copy-and-paste — there's no installer to run.

## What's included

This bundle contains two things:

- **`WSOCK32.dll`** — the [SuperBLT](https://superblt.znix.xyz/) mod loader. This
  is the file the game loads at startup that makes everything else work.
- **`mods/`** — the folder of actual mods, including `mods/base` (the BLT base
  hook that SuperBLT loads on top of).

The mods in this pack:

| Mod | What it does |
| --- | --- |
| `base` | SuperBLT base hook — **required**, loads all the other mods |
| `BeardLib` | Modding framework many other mods depend on |
| `WolfHUD-master` | Replacement HUD with extra info |
| `CustomFOV` | Adjustable field of view |
| `Borderless Windowed Updated` | Borderless windowed mode |
| `CreateEmptyLobby` | Start a solo/empty lobby |
| `Force Start with Chat Command` | Force-start a heist via chat command |
| `Instant Restart` | Restart a heist instantly |
| `InvertedFlashbangGlare` | Changes the flashbang screen effect |
| `Meth Helper Updated` | Cook helper for Rats / Cook Off |
| `No Interaction Cooldowns (Pagerloop bug)` | Removes interaction cooldowns |
| `bloxy cola for stoic` | Reskin/tweak |

## Requirements

You need a normal Steam install of **PAYDAY 2**. The included `WSOCK32.dll` is the
32‑bit SuperBLT loader, which matches the standard 32‑bit PC build of the game
(`payday2_win32_release.exe`). No other prerequisites.

## How to install

1. **Find your PAYDAY 2 install folder.** In Steam, right‑click **PAYDAY 2** →
   **Manage** → **Browse local files**. This opens the folder that contains
   `payday2_win32_release.exe`.

2. **Copy the files in.** Drag both of these into that folder:
   - `WSOCK32.dll`
   - the entire `mods` folder

   When Windows asks about merging the `mods` folder or replacing files, choose
   **yes / merge**.

3. That's it. The final layout should look like:

   ```
   PAYDAY 2/
   ├── payday2_win32_release.exe
   ├── WSOCK32.dll          <-- the mod loader
   └── mods/
       ├── base/            <-- SuperBLT base hook
       ├── BeardLib/
       ├── WolfHUD-master/
       └── ...the rest
   ```

4. **Launch the game** through Steam as normal. SuperBLT loads the mods at
   startup. The first launch may take a little longer while mods initialize.

## Verifying it worked

- A **BLT / mod menu** is reachable from the in‑game Options menu (look for a
  **Mods** entry).
- Mods with visible effects (like **WolfHUD** or **CustomFOV**) will be obviously
  active in‑game.
- Logs are written to `mods/logs/` if you need to troubleshoot.

## Updating or removing mods

- **Update a mod:** replace its folder inside `mods/` with the newer version.
- **Remove a mod:** delete its folder from `mods/`. Don't delete `mods/base` or
  `BeardLib` while other mods still depend on them.
- **Uninstall everything:** delete `WSOCK32.dll` and the `mods` folder from the
  game directory. The game runs unmodded again.

## Notes

- Steam updates to PAYDAY 2 occasionally break BLT mods until they're updated.
  If the game crashes on launch after an update, temporarily remove
  `WSOCK32.dll` to play unmodded while the mods catch up.
- Modded lobbies are best played with friends who run the same mods. Many mods
  here are client‑side and safe in public lobbies, but use good judgement.

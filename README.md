# Voxel Engine (Roblox / Luau)

A Minecraft-style voxel world engine for Roblox, built in four iterations. It generates an infinite, chunked block world on the server, streams chunks to clients, and renders them efficiently on the client.

## Highlights

- **Procedural terrain:** multi-octave fractal noise, with terrain height shaped by continentalness, erosion and peaks-and-valleys noise mapped through piecewise-linear splines (`v3/ServerStorage/Modules/GenerationService`).
- **Greedy meshing:** merges runs of identical blocks into rows, then planes, then boxes, cutting the part count Roblox has to render (`v3/StarterPlayer/StarterCharacterScripts/WorldRenderer.client.lua`).
- **Parallel chunk building:** chunk meshing is split across 16 Actors using Parallel Luau (`task.desynchronize`), so loading chunks doesn't stall the game.
- **Sparse "Tensor" structure:** an n-dimensional table that allocates its inner levels lazily, so empty space costs no memory (`v3/ReplicatedStorage/Modules/Utility/Tensor.lua`).
- **Server-to-client streaming:** the client requests chunks within its render distance; the server generates and sends them, and pushes block updates as they happen.
- **Block placing and breaking:** build and break tools that update the world grid and re-mesh only what changed.
- **Strict typing:** v4 is a rewrite in strict-mode Luau (`--!strict`) with exported types.

## Versions

| Folder | What changed |
|---|---|
| `v1` | First version: chunk system, fractal noise terrain, server request framework, player data and HUD. |
| `v2` | Faster world generation, breadth-first chunk loading, and a first move to worker threads. |
| `v3` | Main version: rebuilt renderer with greedy meshing, 16 parallel Actors, spline-shaped terrain, sparse tensor storage, build and break tools. |
| `v4` | Early strict-typed rewrite of the chunk and generation core. |

## Layout

The code was written in Roblox Studio and extracted from the place files. Folders mirror the Roblox Explorer tree (`ServerScriptService`, `ReplicatedStorage`, …). File suffixes follow the Rojo convention:

- `.server.lua`: server `Script`
- `.client.lua`: `LocalScript`
- `.lua`: `ModuleScript`

Only my own code is included. Third-party libraries the place files used (ProfileService, Promise, PartCache, GoodSignal, Binder, base93, WorkerThreads, HD Admin) and Roblox's default player scripts were left out, so the code won't run on its own without them.

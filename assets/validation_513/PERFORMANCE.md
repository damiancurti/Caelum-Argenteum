# #133 native performance controls

Engine simulation and RenderOverlay callbacks in background; not presented/displayed FPS. Actor/projectile counts are sampled every 35 tics, not instantaneous peaks. Different new-city calendar, geometry and carbine behavior are a combined workload, not an isolated geometry delta.

| Scenario | Tics | Tics/s | Render callbacks/s | Render median/p95 ms |
| --- | --- | ---: | ---: | ---: |
| full army, old geometry | 350–3500 | 27.16 | 1.69 | 616.75 / 798.17 |
| staged army, old geometry | 350–3500 | 34.99 | 57.82 | 16.60 / 24.81 |
| occupied peaceful city | 350–1715 | 35.01 | 59.96 | 16.60 / 17.91 |
| scheduled exit | 1750–3500 | 34.90 | 47.64 | 17.07 / 34.70 |
| deployment and buildup | 3500–7000 | 35.00 | 23.46 | 25.15 / 132.72 |
| later combined workload | 7000–10500 | 32.25 | 14.07 | 39.92 / 219.75 |
| 600 living firearm component: fire and reload | 70–490 | 35.02 | 51.61 | 16.67 / 26.78 |
| thermal attrition after firing stops | 490–1400 | 35.00 | 58.74 | 16.64 / 20.41 |
| post-attrition corpses; not sustained fire | 1400–3500 | 35.00 | 60.00 | 16.63 / 17.70 |

Population, shots, reloads, projectile ranges, exact phase endpoints and package hashes are in PERFORMANCE.json.
The firearm component uses all 600 original housed actors and stationary diagnostic targets, with staggered four-tic attack requests and native recovery. It does not measure natural target selection or deployment.
All 600 shoot 14 rounds, finish one reload and then stop firing. Thermal damage kills all of them by tic 1400; HEAT_LIMIT.json confirms the cause in native saved state. Later cheap rendering is not evidence of sustained live firearm performance. No thermal balance or resources were overridden.

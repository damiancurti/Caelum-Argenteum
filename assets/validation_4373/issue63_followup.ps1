$ErrorActionPreference='Stop'
& ./build/run_issue63.ps1 -Label task_start -Commands 'wait 100; give Issue63Matrix; wait 35; give Issue63TaskStart; wait 35; save issue63_pending; wait 20; quit' -Wait
& ./build/run_issue63.ps1 -Label task_reload -LoadSave build/issue63_saves/issue63_pending.zds -Commands 'wait 100; give Issue63TaskResume; wait 35; quit' -Wait
& ./build/run_issue63.ps1 -Label plan_reload -BaseMap build/issue63_ui -LoadSave build/issue63_saves/issue63_plan_ui.zds -Commands 'wait 100; give Issue63PlanReload; wait 35; quit' -Wait
& ./build/run_issue63.ps1 -Label lost_first -LoadSave build/issue63_saves/issue63_crafted.zds -Commands 'wait 100; give Issue63LostFirst; give Issue63Exit; wait 350; quit' -Wait

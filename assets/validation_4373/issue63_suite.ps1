$ErrorActionPreference='Stop'
New-Item -ItemType Directory -Path build/issue63_migration -Force | Out-Null
Copy-Item -LiteralPath build/caelum_argenteum_dev.pk3 -Destination build/issue63_migration/issue63_baseline_4372.pk3
& ./build/run_issue63.ps1 -Label legacy_final -Runtime build/issue63_baseline_4372.pk3 -Fixture build/issue63_legacy -Commands 'wait 100; give Issue63Pre; save issue63_pre; wait 20; give Issue63Post; save issue63_post; wait 20; give Issue63Completed; save issue63_complete; wait 20; quit' -Wait
foreach($case in @('pre','post','complete')) {
    & ./build/run_issue63.ps1 -Runtime build/issue63_migration/issue63_baseline_4372.pk3 -Label "migration_$case" -LoadSave "build/issue63_saves/issue63_$case.zds" -Commands "wait 100; give Issue63Migration; wait 20; save issue63_migrated_$case; wait 20; quit" -Wait
}
& ./build/run_issue63.ps1 -Runtime build/issue63_migration/issue63_baseline_4372.pk3 -Label migration_reload -LoadSave build/issue63_saves/issue63_migrated_post.zds -Commands 'wait 100; give Issue63Migration; wait 20; quit' -Wait
& ./build/run_issue63.ps1 -Label rollback -Runtime build/issue63_baseline_4372.pk3 -Fixture build/issue63_legacy -LoadSave build/issue63_saves/issue63_post.zds -Commands 'wait 100; save issue63_rollback_copy; wait 20; quit' -Wait
& ./build/run_issue63.ps1 -Label exit_final -Commands 'wait 100; give Issue63Matrix; wait 35; give Issue63Craft; wait 35; save issue63_crafted; wait 35; give Issue63Exit; wait 450; save issue63_arrival_final; wait 35; quit' -Wait
& ./build/run_issue63.ps1 -Label arrival_final -LoadSave build/issue63_saves/issue63_arrival_final.zds -Commands 'wait 240; quit' -Wait

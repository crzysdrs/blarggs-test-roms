# Blargg's Reproducible Test Roms

## Goal

Reproduce all of blargg's GameBoy test ROMs from source as an aid to debugging GameBoy emulators.

## Build

This project uses python3 to generate a Ninja file to build the ROMs. A makefile would have been easier but many of the filenames contained spaces and Makefiles do not support them effectively. All created ROMs will be emitted to the `roms/` subdirectory.

All ROMs currently built with [wla-dx](https://github.com/vhelin/wla-dx).

```
python3 ninja.py && ninja
```

## Status
Successful ROMS: 59/66 (89.39%)

| Test ROM | MD5 CheckSum | Result |
| --- | --- | --- |
| cgb_sound/01-registers.gb | `f65df81d88a7f6eceeebf0097634aa8f` | <span style="color:green">OK</span> |
| cgb_sound/02-len ctr.gb | `4da68c214ff70cbb8ce61cc7b479c42b` | <span style="color:green">OK</span> |
| cgb_sound/03-trigger.gb | `3113d6041a249759d4e5d5dc216b2b53` | <span style="color:green">OK</span> |
| cgb_sound/04-sweep.gb | `c6753495f26add8cea10bb99c376f4bd` | <span style="color:green">OK</span> |
| cgb_sound/05-sweep details.gb | `084dd97ec6c69a87bdb8f8de1e12e27f` | <span style="color:green">OK</span> |
| cgb_sound/06-overflow on trigger.gb | `c43939a0b2a75c135a35b0cf322a4d43` | <span style="color:green">OK</span> |
| cgb_sound/07-len sweep period sync.gb | `2990c78566e009f6aefc1c7d1186b746` | <span style="color:green">OK</span> |
| cgb_sound/08-len ctr during power.gb | `c088dc42e1751334941b41e57a0c3602` | <span style="color:green">OK</span> |
| cgb_sound/09-wave read while on.gb | `3dc968d188784e47f2fd26f27f285b31` | <span style="color:green">OK</span> |
| cgb_sound/10-wave trigger while on.gb | `3c2161f7c12097d387cc0bf012be82d4` | <span style="color:green">OK</span> |
| cgb_sound/11-regs after power.gb | `3fed9f54a00299ccdce18a92ecc0b9bc` | <span style="color:green">OK</span> |
| cgb_sound/12-wave.gb | `f6a581a7071d9a560a64be363918b553` | <span style="color:green">OK</span> |
| cgb_sound/cgb_sound.gb | `612dcc096456e42f070e854a3bc5463a` | <span style="color:red">FAIL: Multipart ROM</span> |
| cpu_instrs/01-special.gb | `7d95af543a521ed036dc85f6f232d103` | <span style="color:green">OK</span> |
| cpu_instrs/02-interrupts.gb | `d36a85bb94d4c1b373c0e7be0f6f0971` | <span style="color:green">OK</span> |
| cpu_instrs/03-op sp,hl.gb | `5bccf6b03f661d92b2903694d458510c` | <span style="color:green">OK</span> |
| cpu_instrs/04-op r,imm.gb | `e97a5202d7725a3caaf3495e559f2e98` | <span style="color:green">OK</span> |
| cpu_instrs/05-op rp.gb | `43fc8bfc94938b42d8ecc9ea8b6b811a` | <span style="color:green">OK</span> |
| cpu_instrs/06-ld r,r.gb | `24da4eed7ef73ec32aae5ffd50ebec55` | <span style="color:green">OK</span> |
| cpu_instrs/07-jr,jp,call,ret,rst.gb | `6dbf4e754ef2f844246fd08718d1c377` | <span style="color:green">OK</span> |
| cpu_instrs/08-misc instrs.gb | `c21ddacbfa44d61919c8e2d6c3e7d26e` | <span style="color:green">OK</span> |
| cpu_instrs/09-op r,r.gb | `e4c4dd4eebad0c9d6f2ef575331c3aee` | <span style="color:green">OK</span> |
| cpu_instrs/10-bit ops.gb | `64632849778ee83ae85db8bf68c84ebc` | <span style="color:green">OK</span> |
| cpu_instrs/11-op a,(hl).gb | `6e64346be4d7ccf26f53de105d6cb5f6` | <span style="color:green">OK</span> |
| cpu_instrs/cpu_instrs.gb | `662f04537286d13ee55a6df9de4dce24` | <span style="color:red">FAIL: Multipart ROM</span> |
| dmg_sound/01-registers.gb | `c89dcc0761693f0a42baf6c6a560222f` | <span style="color:green">OK</span> |
| dmg_sound/02-len ctr.gb | `6473a525d5ac88166abf834d83a87aef` | <span style="color:green">OK</span> |
| dmg_sound/03-trigger.gb | `8c0fc255250a20767cbc69e38e2fd945` | <span style="color:green">OK</span> |
| dmg_sound/04-sweep.gb | `62cc099e5ae87ad498a756a68113e79a` | <span style="color:green">OK</span> |
| dmg_sound/05-sweep details.gb | `999232ac83f639a55743432a21149551` | <span style="color:green">OK</span> |
| dmg_sound/06-overflow on trigger.gb | `6840a38816ae9aabe5c573b1d68e77d2` | <span style="color:green">OK</span> |
| dmg_sound/07-len sweep period sync.gb | `ca858a1ff9850e3e5c0e67a23913f47e` | <span style="color:green">OK</span> |
| dmg_sound/08-len ctr during power.gb | `554736cb56fa3eecfdbcc3dfe33ea158` | <span style="color:green">OK</span> |
| dmg_sound/09-wave read while on.gb | `f5dcc6b28f1795cc7cd14c16262f158c` | <span style="color:green">OK</span> |
| dmg_sound/10-wave trigger while on.gb | `f2a6e1c4a34bfe501b26f4e1e02e4d85` | <span style="color:green">OK</span> |
| dmg_sound/11-regs after power.gb | `489878d2529014556d852df9f043fd07` | <span style="color:green">OK</span> |
| dmg_sound/12-wave write while on.gb | `bf7c0da1e5ad89a5809d607a3c3d0888` | <span style="color:green">OK</span> |
| dmg_sound/dmg_sound.gb | `cf1a393540f001fb3a7f2da1bc7fbc3f` | <span style="color:red">FAIL: Multipart ROM</span> |
| halt_bug.gb | `93bdd72292b1f1c25290c7a3ae8b37b3` | <span style="color:red">FAIL: Missing Source</span> |
| instr_timing/instr_timing.gb | `b417d5d06c3382ab5836b5d365184f36` | <span style="color:green">OK</span> |
| interrupt_time/interrupt_time.gb | `9ff2376e37bc1e472e6f349ecd453b85` | <span style="color:green">OK</span> |
| mem_timing-2/01-read_timing.gb | `47550d1bd635c0786f182cc1c19c6704` | <span style="color:green">OK</span> |
| mem_timing-2/02-write_timing.gb | `688031034810e8065e5819acf650103d` | <span style="color:green">OK</span> |
| mem_timing-2/03-modify_timing.gb | `758281d0945a50c870a325b3c730ec36` | <span style="color:green">OK</span> |
| mem_timing-2/mem_timing.gb | `94fca018fdf41b618e8fbe6638352653` | <span style="color:red">FAIL: Multipart ROM</span> |
| mem_timing/01-read_timing.gb | `9537182264201f75611fc96a1de0f086` | <span style="color:green">OK</span> |
| mem_timing/02-write_timing.gb | `d5cf8017991700f267b7b753579cc773` | <span style="color:green">OK</span> |
| mem_timing/03-modify_timing.gb | `fd3516dca15be20bc124ce4523ae5ad3` | <span style="color:green">OK</span> |
| mem_timing/mem_timing.gb | `4218b63c50350868cb4ebdef0a17429b` | <span style="color:red">FAIL: Multipart ROM</span> |
| oam_bug-2/1-lcd_sync.gb | `456c37a4763bfa1f409e3940418a3833` | <span style="color:green">OK</span> |
| oam_bug-2/2-causes.gb | `2c4ab6055fa59514b4b26fd39a6bc6cb` | <span style="color:green">OK</span> |
| oam_bug-2/3-non_causes.gb | `ffada50bbb6cc5f61803d04a98df2be5` | <span style="color:green">OK</span> |
| oam_bug-2/4-scanline_timing.gb | `8886b294f39e7be17540d800f6af88d9` | <span style="color:green">OK</span> |
| oam_bug-2/5-timing_bug.gb | `83396ea02a657863b2165ad54103299b` | <span style="color:green">OK</span> |
| oam_bug-2/6-timing_no_bug.gb | `4a8171930f611efc289a409f5e2559f9` | <span style="color:green">OK</span> |
| oam_bug-2/7-timing_effect.gb | `6b6e3e2340060910d2b18a00eef0deee` | <span style="color:green">OK</span> |
| oam_bug-2/8-instr_effect.gb | `149827759d5671f0ccfdf9420162186f` | <span style="color:green">OK</span> |
| oam_bug/1-lcd_sync.gb | `45136c3c6c359be1eb3c313238816e1d` | <span style="color:green">OK</span> |
| oam_bug/2-causes.gb | `24c9d248efd12ccd5b46bf1d8861ccd3` | <span style="color:green">OK</span> |
| oam_bug/3-non_causes.gb | `743662f11f816e39cb3432deec5333b1` | <span style="color:green">OK</span> |
| oam_bug/4-scanline_timing.gb | `115dea4eb8629cf32a6fbdd413dfae1a` | <span style="color:green">OK</span> |
| oam_bug/5-timing_bug.gb | `5818f6365366880246cf1dbb272150a1` | <span style="color:green">OK</span> |
| oam_bug/6-timing_no_bug.gb | `999ab335f59be2f7d5bab31e21990fcd` | <span style="color:green">OK</span> |
| oam_bug/7-timing_effect.gb | `c71e334a9ae772953deb2c0949e7e467` | <span style="color:green">OK</span> |
| oam_bug/8-instr_effect.gb | `300802bb284fe922c59d94cadb4c8b6f` | <span style="color:green">OK</span> |
| oam_bug/oam_bug.gb | `dea628358e91e730e045fa07d8f655d5` | <span style="color:red">FAIL: Multipart ROM</span> |

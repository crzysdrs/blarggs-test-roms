#!/usr/bin/env python3

import ninja_syntax
import glob
import re
import os.path

dirs = [
    #"cgb_sound",
    "cpu_instrs",
#    "dmg_sound",
     "instr_timing",
#     "interrupt_time",
     "mem_timing",
#     "mem_timing-2",
#     "oam_bug",
#
]

n = ninja_syntax.Writer(open("build.ninja", "w"))

n.rule("compile", "wla-gb -I common $dmg_or_cgb $defines $in")
n.rule("makelink", "./makelink $out $in")
n.rule("link", "wlalink -d \"$linkfile\" $out")
n.rule("checksums", "cd roms && md5sum --ignore-missing -c ../$sumfile")

roms = []
for d in dirs:
    for s in glob.glob("{}/*.s".format(d)):
        (name, ext) = os.path.splitext(s)
        print (name)
        compile_vars = {"defines": "-D TEST_NAME=\"{}\"".format(os.path.basename(name))}
        if d == "instr_timing":
            compile_vars["defines"] += " -D ROM_NAME=\"{}\"".format("INSTR_TIMING")

        if d == "dmg_sound":
            compile_vars['dmg_or_cgb'] = "-D REQUIRE_DMG"
        elif d == "cgb_sound":
            compile_vars['dmg_or_cgb'] = "-D REQUIRE_CGB"
        objs = n.build("{}.o".format(name), rule="compile", inputs=[s], variables=compile_vars)
        linkfile = n.build("{}.link".format(name), rule="makelink", inputs=objs)
        link_vars={"linkfile": linkfile[0]}
        roms.extend(n.build("roms/{}.gb".format(name), rule="link", inputs=linkfile + objs, variables=link_vars))

n.build("pass", rule="checksums", inputs=roms, variables={"sumfile":"md5sums"})

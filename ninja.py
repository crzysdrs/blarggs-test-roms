#!/usr/bin/env python3

import ninja_syntax
import glob
import re
import os.path

dirs = [
    "cgb_sound",
    "cpu_instrs",
    "dmg_sound",
    "instr_timing",
#    "interrupt_time",
    "mem_timing",
    "mem_timing-2",
    "oam_bug",
    "oam_bug-2",
]

n = ninja_syntax.Writer(open("build.ninja", "w"))

n.rule("compile", "wla-gb -M $includes $defines $in > $out.d && wla-gb -o $out $includes $defines $in")
n.rule("makelink", "./makelink $out $in")
n.rule("link", "wlalink '$linkfile' $out")
n.rule("checksums", "cd roms && md5sum --ignore-missing -c ../$sumfile")

roms = []
for d in dirs:
    for s in glob.glob("{}/*.s".format(d)):
        (name, ext) = os.path.splitext(s)
        print (name)
        test_name = os.path.basename(name)
        compile_vars = {
            "defines": "-D TEST_NAME=\"{}\"".format(test_name),
            "depfile": "$out.d",
            "includes": "-I {}/common".format(os.path.dirname(name)),
        }
        if d == "interrupt_time":
            compile_vars["includes"] += "-I instr_timing/common -I cpu_instrs/common"
        elif d == "instr_timing":
            compile_vars["defines"] += " -D ROM_NAME=\"{}\"".format("INSTR_TIMING")
        elif d == "mem_timing-2":
            if test_name in ["02-write_timing", "03-modify_timing"]:
                compile_vars["defines"] += ' -D ROM_NAME={}'.format(test_name.upper()[:15])
        elif d == "oam_bug-2":
            compile_vars["defines"] += ' -D ROM_NAME={}'.format(test_name.upper()[:15])
        elif d == "dmg_sound":
            compile_vars['defines'] += " -D REQUIRE_DMG"
        elif d == "cgb_sound":
            compile_vars['defines'] += " -D REQUIRE_CGB"
        objs = n.build("{}.o".format(name), rule="compile", inputs=[s], variables=compile_vars)
        linkfile = n.build("{}.link".format(name), rule="makelink", inputs=objs)
        link_vars={"linkfile": linkfile[0]}
        roms.extend(n.build("roms/{}.gb".format(name), rule="link", inputs=linkfile + objs, variables=link_vars))
n.build("pass", rule="checksums", inputs=roms, variables={"sumfile":"md5sums"})

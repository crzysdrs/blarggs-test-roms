#!/usr/bin/env python3

import ninja_syntax
import glob
import re
import os.path
import sys

dirs = [
    "cgb_sound",
    "cpu_instrs",
    "dmg_sound",
    "instr_timing",
    "interrupt_time",
    "mem_timing",
    "mem_timing-2",
    "oam_bug",
    "oam_bug-2",
]

n = ninja_syntax.Writer(open("build.ninja", "w"))

n.rule("compile", "wla-gb -M $includes $defines $in > $out.d && wla-gb -o $out $includes $defines $in")
n.rule("library", "wla-gb -M $includes $defines $in > $out.d && wla-gb -l $out $includes $defines $in")
n.rule("makelink", "./makelink $out '[objects]' $in")
n.rule("link", "wlalink '$linkfile' $out")
n.rule("sub_bin", "dd if=$in skip=4096 bs=1 of=$out")
n.rule("checksums", "cd roms && md5sum --ignore-missing -c ../$sumfile")

# experimental multipart rom
# for d in ["cpu_instrs"]:
#     for s in glob.glob("{}/*.s".format(d)):
#         (name, ext) = os.path.splitext(s)
#         print (name)
#         lib_name = os.path.basename(name)
#         if lib_name == "top":
#             continue
#         sub_o = n.build("libs/{}.o".format(name), rule="compile", inputs=s, variables={
#             'defines':'-D BUILD_MULTI',
#             "includes": "-I {}/common ".format(d)
#         })
#         link = n.build("libs/{}.link".format(name), rule="makelink", inputs=sub_o)
#         link_vars={"linkfile": link}
#         normal_bin = n.build("libs/{}.gb".format(name), rule="link", inputs=link + sub_o, variables=link_vars)
#         bins = n.build("libs/{}.bin".format(name), rule="sub_bin", inputs=normal_bin)

# sys.exit(0)
# linkfile = n.build("{}.lib.link".format(name), rule="makelink", inputs=libs)
# n.build("libs/{}.gb".format("cpu_instrs"), rule="link", inputs=linkfile + libs, variables=link_vars)

roms = []
for d in dirs:


    for s in glob.glob("{}/*.s".format(d)):
        (name, ext) = os.path.splitext(s)
        print (name)
        test_name = os.path.basename(name)
        if test_name == "top":
            continue

        compile_vars = {
            "defines": "-D 'TEST_NAME=\"{}\"'".format(test_name),
            "depfile": "$out.d",
            "includes": "-I {}/common".format(os.path.dirname(name)),
        }
        if d == "interrupt_time":
            compile_vars["defines"] = " -D 'TEST_NAME=\"{}\"'".format("interrupt time")
        elif d == "instr_timing":
            compile_vars["defines"] += " -D 'ROM_NAME=\"{}\"'".format("INSTR_TIMING")
        elif d == "mem_timing-2":
            if test_name in ["02-write_timing", "03-modify_timing"]:
                compile_vars["defines"] += ' -D \'ROM_NAME="{}"\' '.format(test_name.upper()[:15])
        elif d == "oam_bug-2":
            compile_vars["defines"] += ' -D \'ROM_NAME="{}"\' '.format(test_name.upper()[:15])
        elif d == "dmg_sound":
            compile_vars['defines'] += " -D REQUIRE_DMG"
        elif d == "cgb_sound":
            compile_vars['defines'] += " -D REQUIRE_CGB"
        objs = n.build("{}.o".format(name), rule="compile", inputs=[s], variables=compile_vars)
        linkfile = n.build("{}.link".format(name), rule="makelink", inputs=objs)
        link_vars={"linkfile": linkfile[0]}
        roms.extend(n.build("roms/{}.gb".format(name), rule="link", inputs=linkfile + objs, variables=link_vars))
n.build("pass", rule="checksums", inputs=roms, variables={"sumfile":"md5sums"})

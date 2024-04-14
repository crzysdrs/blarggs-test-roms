#!/usr/bin/env python3

import ninja_syntax
import glob
import re
import os.path
import sys
from collections import defaultdict
import itertools

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

n.rule(
    "compile",
    "wla-gb -M $includes $defines $in > $out.d && wla-gb -o $out $includes $defines $in",
)
n.rule("makelink", "./makelink $out '[objects]' $in")
n.rule("link", "wlalink -S $linkfile $out")
n.rule("checksums", "cd roms && md5sum --ignore-missing -c ../$sumfile")

multis = defaultdict(list)


def multipart_roms(d, s, defines, includes):
    (name, ext) = os.path.splitext(s)
    if s.find("cpu_instrs") < 0:
        return None
    lib_name = os.path.basename(name)
    defines.pop("ROM_NAME", "")
    defines.pop("TEST_NAME", "")
    defines["BUILD_MULTI"] = 1
    includes = ["multi/common"]
    compile_vars = get_compile_vars(defines, includes)
    sub_o = n.build(
        "libs/{}.o".format(name), rule="compile", inputs=[s], variables=compile_vars
    )
    link = n.build("libs/{}.link".format(name), rule="makelink", inputs=sub_o)
    link_vars = {"linkfile": escape_both(link[0])}
    normal_bin = n.build(
        "libs/{}.multi.gb".format(name),
        rule="link",
        inputs=link + sub_o,
        variables=link_vars,
    )
    multis[d] += normal_bin


def create_define(k, v):
    try:
        int(v)
        return ["-D", "{}=0{:x}h".format(k, int(v))]
    except:
        return ["-D", '{}="{}"'.format(k, v)]


def escape_shell(v):
    v = re.sub(r"""(['"\{\}\(\)\[\]\+\*\\\$])""", r"\\\1", v)
    return v


def escape_ninja(v):
    v = re.sub("\$", "$$", v)
    v = re.sub(" ", "$ ", v)
    return v

def escape_both(v):
    return escape_ninja(escape_shell(v))

def get_compile_vars(defines, includes, other=None):
    defines = [create_define(k, v) for k, v in defines.items()]
    defines = itertools.chain.from_iterable(defines)

    compile_vars = {
        "defines": " ".join([escape_both(d) for d in defines]),
        "depfile": "$out.d",
        "includes": " ".join(
            ["-I {}".format(escape_both(i)) for i in includes]
        ),
    }
    if other:
        compile_vars += other
    return compile_vars


roms = []
for d in dirs:
    for s in glob.glob("{}/*.s".format(d)):
        (name, ext) = os.path.splitext(s)
        print(name)
        test_name = os.path.basename(name)
        defines = {"TEST_NAME": test_name, "BUGGY_TIMER": 1}
        includes = ["{}/common".format(os.path.dirname(name))]

        if d == "interrupt_time":
            defines["TEST_NAME"] = "interrupt time"
        elif d == "instr_timing":
            defines["ROM_NAME"] = test_name.upper()
        elif d == "mem_timing-2":
            if test_name in ["02-write_timing", "03-modify_timing"]:
                defines["ROM_NAME"] = test_name.upper()
        elif d == "oam_bug-2":
            defines["ROM_NAME"] = test_name.upper()
        elif d == "dmg_sound":
            defines["REQUIRE_DMG"] = 1
        elif d == "cgb_sound":
            defines["REQUIRE_CGB"] = 1

        if "ROM_NAME" in defines:
            defines["ROM_NAME"] = defines["ROM_NAME"][:15]

        compile_vars = get_compile_vars(defines, includes)
        objs = n.build(
            "{}.o".format(name), rule="compile", inputs=[s], variables=compile_vars
        )
        multipart_roms(d, s, defines, includes)
        linkfile = n.build("{}.link".format(name), rule="makelink", inputs=objs)
        link_vars = {"linkfile": escape_both(linkfile[0])}
        roms.extend(
            n.build(
                "roms/{}.gb".format(name),
                rule="link",
                inputs=linkfile + objs,
                variables=link_vars,
            )
        )


for name, l in multis.items():
    l.sort()
    override_checksums = {"cpu_instrs": 0x30F5}
    defines = {
        "ROM_NAME": "CPU_INSTRS",
        "MULTI_TEST_NAME": "cpu_instrs",
        "BUILD_DEVCART": 1,
    }
    includes = ["multi/common"]
    if name in override_checksums:
        defines["OVERRIDE_GLOBAL_CHECKSUM"] = override_checksums[name]

    objs = n.build(
        "{}.multi.o".format(name),
        rule="compile",
        inputs="multi/cpu_instrs.s",
        variables=get_compile_vars(defines, includes),
    )
    linkfile = n.build("{}.link".format(name), rule="makelink", inputs=objs)
    link_vars = {"linkfile": escape_both(linkfile[0])}
    roms.extend(
        n.build(
            "roms/{}/{}.gb".format(name, name),
            rule="link",
            inputs=linkfile + objs,
            variables=link_vars,
        )
    )

n.build("pass", rule="checksums", inputs=roms, variables={"sumfile": "md5sums"})

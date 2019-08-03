#!/usr/bin/env python3
import subprocess
import re

msg = re.compile("^(?:md5sum: )?([^:]+): (.+)$")
md5sum = re.compile("^([^ ]+) +(.+)$")
md5sums= {}
for l in open("md5sums", "r").readlines():
    match = md5sum.match(l)
    assert(match)    
    md5sums[match.group(2)] = match.group(1)

f = open("README.md", "w")

run = subprocess.run(["md5sum", "-c", "../md5sums"], cwd="roms", stdout=subprocess.PIPE, stderr=subprocess.PIPE)
lines = run.stdout.decode("utf-8").splitlines()
lines.sort()

expected = {
    "./oam_bug/oam_bug.gb":"Multipart ROM",
    "./mem_timing/mem_timing.gb":"Multipart ROM",
    "./mem_timing-2/mem_timing.gb":"Multipart ROM",
    "./cgb_sound/cgb_sound.gb":"Multipart ROM",
    "./dmg_sound/dmg_sound.gb":"Multipart ROM",
    "./halt_bug.gb":"Missing Source",
    "./cpu_instrs/cpu_instrs.gb":"Multipart ROM",    
}

header = open(".README.header", "r")

f.write(header.read())

f.write("## Status\n")
total = len(lines)
count = 0
for l in lines:
    match = msg.match(l)
    if match.group(2) == "OK":
        count += 1

f.write("Successful ROMS: {}/{} ({:.2f}%)\n".format(count, total, 100 * float(count) / total ))
f.write("| {} | {} | {} |\n".format("Test ROM", "MD5 CheckSum", "Result"))

for l in lines:
    match = msg.match(l)
    assert(match)
    check = "0xfff"
    test = match.group(1)[2:]
    check = md5sums[match.group(1)]
    if match.group(2) == "FAILED open or read":
        f.write("| {} | {} | {} |\n".format(test, check, '<span style="color:red">{}</span>'.format(expected[match.group(1)])))
    elif match.group(2) == "OK":
        f.write("| {} | {} | {} |\n".format(test, check, '<span style="color:green">OK</span>'))
    else:
        raise ("Unhandled error: {}".format(match.group(2)))
    

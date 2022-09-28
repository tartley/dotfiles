#!/usr/bin/env python

import sys
import xml.dom.minidom
content = xml.dom.minidom.parse(sys.stdin)
for line in content.toprettyxml().splitlines():
    if line == '' or line.strip() != '':
        print line


#!/usr/bin/env python

# Neova Health
# Helper script to convert VBox .ova export for import to VMWare ESXi
# Expects OVF v1.0 export from VBox (Developed using 4.3.26); Successfully imports on ESXi 5.5.0

# usage:
#        conv-ova4vmx.py some-vbox-export.ova

import sys
import tarfile
import os
import hashlib

# Takes input e.g. some-vbox-export.ova
vboxfile = sys.argv[1]
fileName,fileExtension = os.path.splitext(vboxfile)
esxifile = '%s%s%s' %('esxi-',fileName,'.ova') # Output e.g. esxi-some-vbox-export.ova

# Gets file names from supplied ova file
t = tarfile.open(vboxfile, 'r')
ovaFiles = t.getnames()
print ovaFiles
ovaF = ovaFiles[0];
ovaV = ovaFiles[1];
ovaM = ovaFiles[2];

# Expand the supplied ova file
tar = tarfile.open(vboxfile)
tar.extractall()
tar.close()

# Modify the OVF definition for VMWare
fn = ovaF
fp = open(fn).read()
if hasattr(fp,'decode'): 
    fp = fp.decode('utf-8')

fp = fp.replace('<OperatingSystemSection ovf:id="80">', '<OperatingSystemSection ovf:id="101">')
fp = fp.replace('<vssd:VirtualSystemType>virtualbox-2.2', '<vssd:VirtualSystemType>vmx-7')
fp = fp.replace('<rasd:Caption>sataController', '<rasd:Caption>scsiController')
fp = fp.replace('<rasd:Description>SATA Controller', '<rasd:Description>SCSI Controller')
fp = fp.replace('<rasd:ElementName>sataController', '<rasd:ElementName>scsiController')
fp = fp.replace('<rasd:ResourceSubType>AHCI', '<rasd:ResourceSubType>lsilogic')
fp = fp.replace('<rasd:ResourceType>20', '<rasd:ResourceType>6')

end = fp.find('<rasd:Caption>sound')
start = fp.rfind('<Item>', 0, end)
fp = fp[:start] + '<Item ovf:required="false">' + fp[start+len('<Item>'):]

nfp = open(fn, 'wb')
nfp.write(fp.encode('utf8'))
nfp.close()

# Calculate the sha1sum of the OVF and vmdk
fovaF = open(ovaF).read()
sovaF = hashlib.sha1(fovaF).hexdigest()

fovaV = open(ovaV).read()
sovaV = hashlib.sha1(fovaV).hexdigest()

of = open(ovaM,"w") # opens file
of.write(('%s%s%s%s' %('SHA1 (',ovaF,')= ',sovaF)) + '\n' + ('%s%s%s%s' %('SHA1 (',ovaV,')= ',sovaV)))
of.close()

# Create new .ova
tar = tarfile.open(esxifile, "w")
for name in ovaFiles:
    tar.add(name)
tar.close()

# Tidy up
for name in ovaFiles:
    os.remove(name)

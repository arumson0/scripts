# This is a script designed to process Bader charges.

# Takes the interface name.
echo $1 > /dev/null
if [ "$1" = "" ]; then
  echo "No interface specified. Aborting."
  exit 1
fi

metal=${1%-mos2}

echo $2 > /dev/null
if [ "$2" = "--proc" ]; then
  proccubes=true
else
  proccubes=false
fi


if $proccubes
then
  # Write and run critic2 input for full interface.
  echo "Processing interface"
  echo "crystal $1.rho.cube
  load $1.rho.cube id rho
  load $1.rhoae.cube id rhoae
  reference rhoae
  integrable rho
  yt" > int.cri
  critic2 < int.cri > int.cro
  echo "DONE"
  
  # Write and run critic2 input file for MoS2 layer
  echo "Processing MoS2 layer"
  echo "crystal prist_mos2.rho.cube
  load prist_mos2.rho.cube id rho
  load prist_mos2.rhoae.cube id rhoae
  reference rhoae
  integrable rho
  yt" > mos2.cri
  critic2 < mos2.cri > mos2.cro
  echo "DONE"
  
  # Write and run critic2 input file for metal slab
  echo "Processing metal slab"
  echo "crystal ag_slab.rho.cube
  load ag_slab.rho.cube id rho
  load ag_slab.rhoae.cube id rhoae
  reference rhoae
  integrable rho
  yt" > slab.cri
  critic2 < slab.cri > slab.cro
  echo "DONE"
fi

natoms=$(grep "Number of atoms in the unit cell:" int.cro | awk '{print $8}')
echo $natoms
nmos2=$(grep "Number of atoms in the unit cell:" mos2.cro | awk '{print $8}')
echo $nmos2
nslab=$(grep "Number of atoms in the unit cell:" slab.cro | awk '{print $8}')
echo $nslab

rhoint=$(grep -A $natoms "# Id   cp   ncp   Name  Z   mult     Volume" int.cro | tail -n $natoms | awk '{print $NF}')
rhomos2=$(grep -A $nmos2 "# Id   cp   ncp   Name  Z   mult     Volume" mos2.cro | tail -n $nmos2 | awk '{print $NF}')
rhoslab=$(grep -A $nslab "# Id   cp   ncp   Name  Z   mult     Volume" slab.cro | tail -n $nslab | awk '{print $NF}')

i=$(awk "BEGIN {print ($natoms + 4) }")
atomsz=$(grep -A $i '+ List of atoms in Cartesian coordinates (bohr):' int.cro | tail -n $natoms | awk '{print $4}')

echo $rhoint > rhoint.dat
echo $rhomos2 > rhomos2.dat
echo $rhoslab > rhoslab.dat
echo $atomsz > atomsz.dat

echo "import numpy as np

rhoint=np.loadtxt('./rhoint.dat')
rhomos2=np.loadtxt('./rhomos2.dat')
rhoslab=np.loadtxt('./rhoslab.dat')
atomsz=np.loadtxt('./atomsz.dat')

rhoref=np.concatenate((rhomos2,rhoslab), axis=None)

deltarho = rhoint - rhoref

allData=np.vstack((atomsz,deltarho)).T

np.savetxt('temp.dat', allData)
" > consolData.py

python3 consolData.py
sort -k1g temp.dat > zdrho.dat
rm temp.dat

echo "import numpy as np
def split_array_based_on_threshold(arr, threshold):
    result = []
    current_subarray = [arr[0]]
    for i in range(1, len(arr)):
        if abs(arr[i] - current_subarray[-1]) <= threshold:
            current_subarray.append(arr[i])
        else:
            result.append(np.array(current_subarray))
            current_subarray = [arr[i]]

    result.append(np.array(current_subarray))
    return result

data = np.loadtxt('./zdrho.dat')

z = data[:,0]
drho = data[:,1]
atomicLayers = split_array_based_on_threshold(data[:,0],1.0)

count = 0
layerCharges = np.array([])
zPositions = np.array([])
zStds = np.array([])
netLayerCharge = np.array([])
for j, subarray in enumerate(atomicLayers):
    rho = np.array([])
    zp = np.array([])
    l=subarray.size
    for i in range(count, count + l,1):
        rho=np.append(rho,drho[i])
        zp=np.append(zp,z[i])
    avgbq = np.average(rho)
    sumbq = np.sum(rho)
    avgzp = np.average(zp)
    stdzp = np.std(zp)
    layerCharges = np.append(layerCharges,avgbq)
    zPositions = np.append(zPositions,avgzp)
    zStds = np.append(zStds,stdzp)
    netLayerCharge = np.append(netLayerCharge,sumbq)
    count = count + l

QMoS2 = 0
for i in range(0,3):
  QMoS2 = QMoS2 + netLayerCharge[i]

QMetal = 0
for i in range(3,len(netLayerCharge)):
  QMetal = QMetal + netLayerCharge[i]

print('net excess charge on the MoS2 layer:')
print(QMoS2)

print('net excess charge on the metal slab:')
print(QMetal)

print('Net excess charge in the system:')
print(np.sum(netLayerCharge))
print('^ This number should be ZERO')

# Average distance between the Mos2 and the metal:
p1 = zPositions[2]
ep1 = zStds[2]
p2 = zPositions[3]
ep2 = zStds[3]
dist = (p2 - p1)*0.529177
ddist = ((ep2**2 + ep1**2)**0.5)*0.529177
print('Distance between the contact sulfur and metal is:')
print(dist)
print('With error:')
print(ddist)

from matplotlib import rcParamsDefault
import matplotlib as mpl
from mpl_toolkits.axes_grid1 import make_axes_locatable
import matplotlib.pyplot as plt
import matplotlib.patches as patches


font = {'family' : 'Helvetica',
        'size'   : 24}

mpl.rc('font', **font)

plt.rcParams['figure.dpi']=150
plt.rcParams['figure.facecolor']='white'
plt.rcParams['lines.markersize']=15
plt.rcParams['figure.figsize']=(8,5)
mpl.rcParams['axes.linewidth'] = 3

numLayers = layerCharges.size
objects = ['S','Mo','S']
stringFromAbove = '$metal'
for i in range(numLayers-3):
  objects.append(stringFromAbove.title())
print(objects)

fig, ax = plt.subplots()

for i in range(0,3):
    plt.bar(zPositions[i],layerCharges[i],align='center',color='#0079FA',width=2,edgecolor ='black')
for i in range(3,layerCharges.size):
    plt.bar(zPositions[i],layerCharges[i],align='center',color='#00D302',width=2,edgecolor ='black')

for i in range(len(objects)):
    plt.text(zPositions[i],min(layerCharges)-0.37,objects[i], ha='center', va='center')
    if layerCharges[i] > 0:
        plt.text(zPositions[i],layerCharges[i]+0.1,round(layerCharges[i],2), ha='center', va='center',fontsize=14)
    elif layerCharges[i] < 0:
        plt.text(zPositions[i],layerCharges[i]-0.1,round(layerCharges[i],2), ha='center', va='center',fontsize=14)

plt.axhline(y = 0.0, color = 'k',linestyle='--')
plt.ylim(min(layerCharges)-0.55, max(layerCharges)+0.35)
plt.ylabel('Bader charge difference (e)',fontsize=20)
plt.xlabel('Atomic layer')
plt.tick_params(axis='x', which='both', bottom=False, labelbottom=False, width=3)
plt.tight_layout()
plt.savefig('$metal-mos2_bader.png')
#plt.show()
" > layerBaderAndPlot.py

python3 layerBaderAndPlot.py
echo "Bader charges processed. Never give up! Never surrender!"

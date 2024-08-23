import matplotlib.pyplot as plt
from matplotlib import rcParamsDefault
import numpy as np
import matplotlib as mpl
from mpl_toolkits.axes_grid1 import make_axes_locatable
from matplotlib.patches import Patch
from matplotlib.lines import Line2D
import glob

font = {'family' : 'Helvetica',
        'size'   : 24}

mpl.rc('font', **font)

plt.rcParams["figure.dpi"]=150
plt.rcParams["figure.facecolor"]="white"
plt.rcParams['lines.markersize']=15
plt.rcParams["figure.figsize"]=(8,5)
mpl.rcParams['axes.linewidth'] = 3

data = 1000*np.loadtxt("./ecutSummary.dat")

plt.plot(data[:,0]/1000, data[:,1]-data[7,1],'#0079FA',lw=3,label=r'MoS$_2$')
plt.scatter(data[:,0]/1000, data[:,1]-data[7,1],color='#0079FA')
plt.plot(data[:,0]/1000, data[:,2]-data[7,2],'#A40122',lw=3,label=r'2H-BS')
plt.scatter(data[:,0]/1000, data[:,2]-data[7,2],color='#A40122')
plt.plot(data[:,0]/1000, data[:,3]-data[7,3],'#00D302',lw=3,label=r'C$_3$B')
plt.scatter(data[:,0]/1000, data[:,3]-data[7,3],color='#00D302')
plt.plot(data[:,0]/1000, data[:,4]-data[15,4],'#450270',lw=3,label=r'PST')
plt.scatter(data[:,0]/1000, data[:,4]-data[15,4],color='#450270')
plt.plot(data[:,0]/1000, data[:,5]-data[11,5],'#FF5AAF',lw=3,label=r'PSH')
plt.scatter(data[:,0]/1000, data[:,5]-data[11,5],color='#FF5AAF')

plt.legend(loc=1,fontsize=16)
#plt.axvline(x = 35.0, color = 'k', linestyle = '--')
plt.xlabel("Ecut (Ha)")
plt.ylabel('Relative Energy (mHa)')
plt.ylim([-0.75, 6.5])
plt.xlim([12, 68])
#plt.gca().set_ylim(bottom=0)
#plt.title(r"Pt-MoS$_2$")
plt.tight_layout()
plt.savefig("ecutConvergence.png")
plt.show()

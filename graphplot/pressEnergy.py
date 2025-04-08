# This code has two parts, 
#1. Read a csv file with information of 
# total energy under different pressure of each compounds.
#2. Plot the energy-pressure graph.
import matplotlib as mpl
import matplotlib.pyplot as plt
import numpy as np

def pERead():
    plotData = {'UP$_2$':([0,5,10,15,20],[0,-6,-7,-8,-4]),'UAs_2':([0,5,10,15,20],[0,-2,-7,-8,-4])}
    return plotData

def pEplot(plotData):
    def plotOneData(titleName,pETuple,colorPoint=None,colorLine=None):
        #mpl.rcParams['lines.linewidth'] = 1
        if colorPoint==None:
            colorPoint='firebrick'
        if colorLine==None:
            colorLine='darkturquoise'
        p = [str(press) for press in pETuple[0]]
        E = pETuple[1]
        fig, ax = plt.subplots()
        ax.plot(p,E,color=colorLine,linewidth=3.0,linestyle='-',zorder=1)
        ax.scatter(p,E,color=colorPoint,marker='o',zorder=2)
        ax.set(xlabel = 'Pressure(GPa)', ylabel = 'Total Energy(eV)',\
               title = 'Press-Energy of ${tN}$'.format(tN=titleName))
        ax.grid()
        plt.show()

    for compound in plotData.keys():
        plotOneData(compound,plotData.get(compound))
        
    

def test_pEplot():
    testData = {'UP_2':([0,5,10,15,20],[0,-6,-7,-8,-4]),'UAs_2':([0,5,10,15,20],[0,-2,-7,-8,-4])}
    pEplot(testData)


if __name__ == '__main__':    
    #pEplot(pERead())
    test_pEplot()

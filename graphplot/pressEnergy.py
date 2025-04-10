# This code has two parts, 
#1. Read a csv file with information of 
# total energy under different pressure of each compounds.
#2. Plot the energy-pressure graph.
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import os

# Define a dataStructure----a Tree that Compounds--structure--picture, this will be changed to a json file format in future.
# And not only for pressure-energy plot, a dataStructure for pressure-band plot will be difined.
class compounds_data(dict):
    def __init__(self,compounds=None):
        if compounds==None:
            self.compounds={}
        elif not isinstance(compounds, dict):
            raise TypeError("Compounds-data should be a dictionary.")
        else:
            self.compounds=compounds.copy()

    def initialize(self):
        self=compounds_data()

    def add_compounds(self,compounds_key=None):
        if not isinstance(compounds_key, str):
            raise TypeError("compounds-key should be a string.")
        if compounds_key not in self.compounds:
            self.compounds[compounds_key] = {}

    def add_magStruc(self,compounds_key,magStruc_key,pEtuple=None):
        if compounds_key not in self.compounds:
            raise KeyError(f"{compounds_key} does not exist.")
        if not isinstance(magStruc_key,str):
            raise TypeError("magStruc_key should be a string.")
        if magStruc_key not in self.compounds[compounds_key].keys():
            self.compounds[compounds_key][magStruc_key] = []

    def add_pEtuple(self, compounds_key, magStruc_key, pEtuple):
        if compounds_key not in self.compounds:
            raise KeyError(f"{compounds_key} does not exist.")
        if magStruc_key not in self.compounds[compounds_key]:
            raise KeyError(f"{magStruc_key} does not exist.")
        if not isinstance(pEtuple,tuple):
            raise TypeError("pEtuple must be a tuple!")
        if self.compounds[compounds_key][magStruc_key] == []:
            self.compounds[compounds_key][magStruc_key] = [[],[]]
        self.compounds[compounds_key][magStruc_key][0].append(pEtuple[0])
        self.compounds[compounds_key][magStruc_key][1].append(pEtuple[1])       
    
    def add_data(self, comp, mag, press, energy):
        self.add_compounds(comp)
        self.add_magStruc(compounds_key=comp,magStruc_key=mag)
        self.add_pEtuple(compounds_key=comp,magStruc_key=mag,pEtuple=(press,energy))

    

def pERead(filename):
    plotData = compounds_data()
    data = pd.read_csv(filename,sep='_| |GPa_',names=['compounds','press','mag','energy'])
    for row in data.itertuples():
        print(row)
        plotData.add_data(comp=row[1],mag=row[3],press=row[2],energy=row[4])
    return plotData.compounds


# In this code, pEplot is untransfomable. I just define two different plot mode. In future, plot mode for multiple structure will be added.
#pressures = sorted(pETuple[0])
#energies = [e for _, e in sorted(zip(pETuple[0], pETuple[1]))]
def pEplot(plotData):
    def plotOneData(titleName,pETuples,colorPoint=None,colorLine=None):
        if colorPoint==None:
            colorPoint='firebrick'
        if colorLine==None:
            colorLines=[
    '#1f77b4',  '#ffbb78', '#2ca02c', '#98df8a',
    '#d62728', '#ff9896', '#9467bd', '#c5b0d5', '#8c564b', '#c49c94',
    '#e377c2', '#f7b6d2', '#7f7f7f', '#c7c7c7', '#bcbd22', '#dbdb8d',
    '#17becf', '#9edae5']
        fig, ax = plt.subplots()
        colorCount = 0
        for struc in pETuples.keys():
            colorLine = colorLines[colorCount]
            pETuple = pETuples[struc]
            if len(pETuple) != 0:
                pressures = sorted(pETuple[0])
                energies = [e for _, e in sorted(zip(pETuple[0], pETuple[1]))]
                p = [str(press) for press in pressures]
                E = energies
                ax.plot(p,E,color=colorLine,linewidth=2.0,linestyle='-',zorder=1,label="{}".format(struc))
                ax.scatter(p,E,color=colorPoint,marker='o',s=2.5,zorder=2)
                ax.legend()
            colorCount+=1
        ax.set(xlabel = 'Pressure(GPa)', ylabel = 'Total Energy(eV)',\
            title = 'Press-Energy of ${tN}$'.format(tN=titleName))
        ax.grid()
        plt.show()

    for compound in plotData.keys():
        plotOneData(compound,plotData.get(compound))
        
    

def test_pEplot():
    testData = {'UP_2':{'FM':[[0,5,10,15,20],[0,-6,-7,-8,-4]],'AFM':{}},'UAs_2':{'AFM':([0,5,10,15,20],[0,-2,-7,-8,-4])}}
    testDataSecond = {'UP_2':{'FM':([0,5,10,15,20],[0,-6,-7,-8,-4]),'AFM':{}},'UAs_2':{'FM':([0,5,10,15,20],[0,-2,-7,-8,-4]),'AFM':([0,5,10,15,20],[0,-6,-7,-8,-4])}}
    pEplot(testData)
    pEplot(testDataSecond)

def test_pERead():
    testfilepath= "D:\\projects\\bandplot\\Bandplot4Vasp\\graphplot\\energyLowpress_test"
 #   testData = {'UP_2':{'FM':([0,5,10,15,20],[0,-6,-7,-8,-4]),'AFM':{}},'UAs_2':{'AFM':([0,5,10,15,20],[0,-2,-7,-8,-4])}}
    return pERead(testfilepath)

if __name__ == '__main__':    
    pEplot(pERead("D:\\projects\\bandplot\\Bandplot4Vasp\\graphplot\\energyLowpress_test"))
    print(pERead("D:\\projects\\bandplot\\Bandplot4Vasp\\graphplot\\energyLowpress_test"))

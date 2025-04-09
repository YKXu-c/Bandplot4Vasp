# This code has two parts, 
#1. Read a csv file with information of 
# total energy under different pressure of each compounds.
#2. Plot the energy-pressure graph.
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd

# Define a dataStructure----a Tree that Compounds--structure--picture, this will be changed to a json file format in future.
# And not only for pressure-energy plot, a dataStructure for pressure-band plot will be difined.
class compounds_data:
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
        if compounds_key not in self.structure:
            self.compounds[compounds_key] = {}

    def add_magStruc(self,compounds_key,magStruc_key,pEtuple=None):
        if compounds_key not in self.compounds:
            raise KeyError(f"{compounds_key} does not exist.")
        if not isinstance(magStruc_key,str):
            raise TypeError("magStruc_key should be a string.")
        #if magStruc_key in self.

        self.compounds[compounds_key][magStruc_key] = pEtuple.copy() if pEtuple else ()

    def add_pEtuple(self, compounds_key, magStruc_key, pEtuple):
        if compounds_key not in self.compounds:
            raise KeyError(f"{compounds_key} does not exist.")
        if magStruc_key not in self.compounds[compounds_key]:
            raise KeyError(f"{magStruc_key} does not exist.")
        if not isinstance(pEtuple,tuple):
            raise TypeError("pEtuple must be a tuple!")
        self.compounds[compounds_key][magStruc_key] = pEtuple
    
    def add_data(self, comp, mag, press, energy):
        pass

    

def pERead(filename):
    data = pd.read_csv(filename,sep='_| ',names=['compounds','press','mag','energy'])


    plotData = compounds_data()

    return plotData


# In this code, pEplot is untransfomable. I just define two different plot mode. In future, plot mode for multiple structure will be added.
def pEplot(plotData):
    def plotOneData(titleName,pETuples,colorPoint=None,colorLine=None):
        if colorPoint==None:
            colorPoint='firebrick'
        if colorLine==None:
            colorLines=[
    '#1f77b4', '#aec7e8', '#ff7f0e', '#ffbb78', '#2ca02c', '#98df8a',
    '#d62728', '#ff9896', '#9467bd', '#c5b0d5', '#8c564b', '#c49c94',
    '#e377c2', '#f7b6d2', '#7f7f7f', '#c7c7c7', '#bcbd22', '#dbdb8d',
    '#17becf', '#9edae5']
        fig, ax = plt.subplots()
        colorCount = 0
        for struc in pETuples.keys():
            colorLine = colorLines[colorCount]
            pETuple = pETuples[struc]
            if len(pETuple) is not 0:
                p = [str(press) for press in pETuple[0]]
                E = pETuple[1]
                ax.plot(p,E,color=colorLine,linewidth=3.0,linestyle='-',zorder=1)
                ax.scatter(p,E,color=colorPoint,marker='o',zorder=2)
            colorCount+=1
        ax.set(xlabel = 'Pressure(GPa)', ylabel = 'Total Energy(eV)',\
            title = 'Press-Energy of ${tN}$'.format(tN=titleName))
        ax.grid()
        plt.show()

    for compound in plotData.keys():
        plotOneData(compound,plotData.get(compound))
        
    

def test_pEplot():
    testData = {'UP_2':{'FM':([0,5,10,15,20],[0,-6,-7,-8,-4]),'AFM':{}},'UAs_2':{'AFM':([0,5,10,15,20],[0,-2,-7,-8,-4])}}
    testDataSecond = {'UP_2':{'FM':([0,5,10,15,20],[0,-6,-7,-8,-4]),'AFM':{}},'UAs_2':{'FM':([0,5,10,15,20],[0,-2,-7,-8,-4]),'AFM':([0,5,10,15,20],[0,-6,-7,-8,-4])}}
    pEplot(testData)
    pEplot(testDataSecond)

def test_pERead():
    testfilepath='./energyLowpress_test'
 #   testData = {'UP_2':{'FM':([0,5,10,15,20],[0,-6,-7,-8,-4]),'AFM':{}},'UAs_2':{'AFM':([0,5,10,15,20],[0,-2,-7,-8,-4])}}
    return pERead(testfilepath)

if __name__ == '__main__':    
    #pEplot(pERead())
    #test_pEplot()
    pEplot(test_pERead())

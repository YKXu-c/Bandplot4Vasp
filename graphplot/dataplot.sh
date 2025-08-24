#==================================================================#
# This code has two parts, 
# 1. Read multiple csv files with information of 
#    total energy, volume, magnetization under different pressure for each compound
# 2. Plot various properties (energy, volume, magnetization, enthalpy) vs pressure
#==================================================================#
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import os
import re
#==================================================================#
# Define a dataStructure----a Tree that Compounds--magnetic structure--data source--properties,
# This structure will store data from multiple files
#==================================================================#
class compounds_data(dict):
    def __init__(self, compounds=None):
        if compounds is None:
            self.compounds = {}
        elif not isinstance(compounds, dict):
            raise TypeError("Compounds-data should be a dictionary.")
        else:
            self.compounds = compounds.copy()

    def initialize(self):
        self = compounds_data()

    def add_compounds(self, compounds_key=None):
        if not isinstance(compounds_key, str):
            raise TypeError("compounds-key should be a string.")
        if compounds_key not in self.compounds:
            self.compounds[compounds_key] = {}

    def add_magStruc(self, compounds_key, magStruc_key):
        if compounds_key not in self.compounds:
            raise KeyError(f"{compounds_key} does not exist.")
        if not isinstance(magStruc_key, str):
            raise TypeError("magStruc_key should be a string.")
        if magStruc_key not in self.compounds[compounds_key]:
            self.compounds[compounds_key][magStruc_key] = {}

    def add_data_source(self, compounds_key, magStruc_key, data_source):
        if compounds_key not in self.compounds:
            raise KeyError(f"{compounds_key} does not exist.")
        if magStruc_key not in self.compounds[compounds_key]:
            raise KeyError(f"{magStruc_key} does not exist.")
        if data_source not in self.compounds[compounds_key][magStruc_key]:
            self.compounds[compounds_key][magStruc_key][data_source] = {
                'pressure': [], 'energy': [], 'volume': [], 'magnetization': [], 'enthalpy': []
            }
    
    def add_data_point(self, compounds_key, magStruc_key, data_source, pressure, energy, volume, magnetization):
        if compounds_key not in self.compounds:
            self.add_compounds(compounds_key)
        if magStruc_key not in self.compounds[compounds_key]:
            self.add_magStruc(compounds_key, magStruc_key)
        if data_source not in self.compounds[compounds_key][magStruc_key]:
            self.add_data_source(compounds_key, magStruc_key, data_source)
        
        # Calculate enthalpy: H = E + P*V
        # Conversion factor: 1 GPa * Å³ = 6.241509e-3 eV
        enthalpy = energy + pressure * volume * 6.241509e-3
        
        self.compounds[compounds_key][magStruc_key][data_source]['pressure'].append(pressure)
        self.compounds[compounds_key][magStruc_key][data_source]['energy'].append(energy)
        self.compounds[compounds_key][magStruc_key][data_source]['volume'].append(volume)
        self.compounds[compounds_key][magStruc_key][data_source]['magnetization'].append(magnetization)
        self.compounds[compounds_key][magStruc_key][data_source]['enthalpy'].append(enthalpy)

def parse_filename(filename):
    """Parse filename to extract compound, pressure, and magnetic structure"""
    pattern = r'([A-Za-z0-9]+)_(\d+)GPa_([A-Za-z]+)'
    match = re.search(pattern, filename)
    if match:
        compound = match.group(1)
        pressure = int(match.group(2))
        magnetism = match.group(3)
        return compound, pressure, magnetism
    return None, None, None

def pERead(filenames):
    """Read multiple data files and populate the compounds_data structure"""
    plotData = compounds_data()
    
    for filename, source_label in filenames.items():
        try:
            data = pd.read_csv(filename, sep='\s+', names=['directory', 'energy', 'volume', 'magnetization'])
            
            for index, row in data.iterrows():
                if pd.isna(row['energy']) or pd.isna(row['volume']) or pd.isna(row['magnetization']):
                    continue
                    
                directory = row['directory']
                compound, pressure, magnetism = parse_filename(directory)
                
                if compound is None:
                    continue
                    
                energy = float(row['energy'])
                volume = float(row['volume'])
                magnetization = float(row['magnetization'])
                
                plotData.add_data_point(
                    compounds_key=compound,
                    magStruc_key=magnetism,
                    data_source=source_label,
                    pressure=pressure,
                    energy=energy,
                    volume=volume,
                    magnetization=magnetization
                )
                
        except FileNotFoundError:
            print(f"Warning: File {filename} not found")
            continue
        except Exception as e:
            print(f"Error reading file {filename}: {e}")
            continue
    
    return plotData.compounds

# In this code, pEplot is enhanced to handle multiple data sources and properties
def pEplot(plotData, properties=['energy', 'volume', 'magnetization', 'enthalpy'], 
           combine_magnetism=True, save_dir=None):
    """Plot properties vs pressure for all compounds"""
    
    # Create save directory if it doesn't exist
    if save_dir and not os.path.exists(save_dir):
        os.makedirs(save_dir)
    
    # Define colors and markers for different data sources and magnetic structures
    colors = {
        'FM': ['#1f77b4', '#ff7f0e', '#2ca02c', '#d62728'],
        'AFM': ['#9467bd', '#8c564b', '#e377c2', '#7f7f7f']
    }
    
    markers = {
        'FM': ['o', 's', '^', 'D'],
        'AFM': ['v', '<', '>', 'p']
    }
    
    property_labels = {
        'energy': 'Total Energy (eV)',
        'volume': 'Volume (Å³)',
        'magnetization': 'Magnetization (μB)',
        'enthalpy': 'Enthalpy (eV)'
    }
    
    # Plot all properties in separate figures for each compound
    for compound in plotData.keys():
        # Create a figure with subplots for each property
        if len(properties) > 1:
            fig, axes = plt.subplots(2, 2, figsize=(12, 10))
            axes = axes.flatten()
        else:
            fig, axes = plt.subplots(1, 1, figsize=(8, 6))
            axes = [axes]
        
        for i, prop in enumerate(properties):
            if i >= len(axes):
                break
                
            ax = axes[i]
            magnetism_types = list(plotData[compound].keys())
            data_sources = set()
            
            # Collect all data sources
            for mag in magnetism_types:
                data_sources.update(plotData[compound][mag].keys())
            
            data_sources = sorted(list(data_sources))
            
            # Plot each data source and magnetic structure
            for data_idx, data_source in enumerate(data_sources):
                for mag_idx, magnetism in enumerate(magnetism_types):
                    if data_source not in plotData[compound][magnetism]:
                        continue
                        
                    data = plotData[compound][magnetism][data_source]
                    if not data['pressure']:
                        continue
                        
                    # Sort by pressure
                    sorted_indices = np.argsort(data['pressure'])
                    pressures = np.array(data['pressure'])[sorted_indices]
                    values = np.array(data[prop])[sorted_indices]
                    
                    # Choose color and marker
                    color_idx = data_idx % len(colors[magnetism])
                    marker_idx = data_idx % len(markers[magnetism])
                    
                    color = colors[magnetism][color_idx]
                    marker = markers[magnetism][marker_idx]
                    
                    # Create label
                    label = f"{data_source}-{magnetism}" if combine_magnetism else f"{data_source}"
                    
                    # Plot
                    ax.plot(pressures, values, color=color, linewidth=2, zorder=1)
                    ax.scatter(pressures, values, color=color, marker=marker, 
                              s=50, label=label, zorder=2)
            
            ax.set_xlabel('Pressure (GPa)')
            ax.set_ylabel(property_labels.get(prop, prop))
            ax.set_title(f'{compound} - {prop.capitalize()} vs Pressure')
            ax.legend()
            ax.grid(True, alpha=0.3)
        
        plt.suptitle(f'{compound} - Properties vs Pressure', fontsize=16)
        plt.tight_layout()
        
        # Save figure
        if save_dir:
            plt.savefig(os.path.join(save_dir, f'{compound}_all_properties.png'), 
                       dpi=300, bbox_inches='tight')
        
        plt.show()
        
        # Also create individual plots for each property
        for prop in properties:
            fig, ax = plt.subplots(figsize=(8, 6))
            
            for data_idx, data_source in enumerate(data_sources):
                for mag_idx, magnetism in enumerate(magnetism_types):
                    if data_source not in plotData[compound][magnetism]:
                        continue
                        
                    data = plotData[compound][magnetism][data_source]
                    if not data['pressure']:
                        continue
                        
                    # Sort by pressure
                    sorted_indices = np.argsort(data['pressure'])
                    pressures = np.array(data['pressure'])[sorted_indices]
                    values = np.array(data[prop])[sorted_indices]
                    
                    # Choose color and marker
                    color_idx = data_idx % len(colors[magnetism])
                    marker_idx = data_idx % len(markers[magnetism])
                    
                    color = colors[magnetism][color_idx]
                    marker = markers[magnetism][marker_idx]
                    
                    # Create label
                    label = f"{data_source}-{magnetism}" if combine_magnetism else f"{data_source}"
                    
                    # Plot
                    ax.plot(pressures, values, color=color, linewidth=2, zorder=1)
                    ax.scatter(pressures, values, color=color, marker=marker, 
                              s=50, label=label, zorder=2)
            
            ax.set_xlabel('Pressure (GPa)')
            ax.set_ylabel(property_labels.get(prop, prop))
            ax.set_title(f'{compound} - {prop.capitalize()} vs Pressure')
            ax.legend()
            ax.grid(True, alpha=0.3)
            plt.tight_layout()
            
            # Save individual property plot
            if save_dir:
                plt.savefig(os.path.join(save_dir, f'{compound}_{prop}.png'), 
                           dpi=300, bbox_inches='tight')
            
            plt.show()

def test_pEplot():
    """Test function with sample data"""
    # Create test data
    testData = {
        'UAs2': {
            'FM': {
                'Data#66': {
                    'pressure': [0, 5, 10, 15, 20, 25, 30, 35, 40],
                    'energy': [-97.318, -96.289, -95.547, -94.639, -93.555, -92.434, -91.375, -89.964, -88.158],
                    'volume': [296.26, 267.12, 252.89, 242.17, 233.18, 225.75, 219.37, 212.73, 207.47],
                    'magnetization': [6.423, 6.342, 6.316, 6.325, 6.150, 5.992, 6.329, 6.057, 4.201],
                    'enthalpy': []  # Will be calculated automatically
                },
                'Data#33': {
                    'pressure': [0, 5, 10, 15, 20, 25, 30, 35, 40],
                    'energy': [-97.280, -96.260, -95.520, -94.610, -93.520, -92.400, -91.340, -89.930, -88.120],
                    'volume': [300.00, 270.00, 255.00, 245.00, 235.00, 228.00, 222.00, 215.00, 210.00],
                    'magnetization': [6.400, 6.340, 6.300, 6.320, 6.140, 5.980, 6.320, 6.050, 4.200],
                    'enthalpy': []
                }
            },
            'AFM': {
                'Data#66': {
                    'pressure': [0, 5, 10, 15, 20, 25, 30, 35, 40],
                    'energy': [-97.327, -96.022, -95.278, -94.350, -93.308, -92.215, -91.095, -89.335, -88.344],
                    'volume': [296.26, 267.12, 252.89, 242.17, 233.18, 225.75, 219.37, 212.73, 207.60],
                    'magnetization': [0.001, 0.000, -0.001, 0.000, 0.000, 0.000, 0.000, 0.000, 0.000],
                    'enthalpy': []
                },
                'Data#33': {
                    'pressure': [0, 5, 10, 15, 20, 25, 30, 35, 40],
                    'energy': [-97.300, -96.000, -95.250, -94.320, -93.280, -92.180, -91.060, -89.300, -88.310],
                    'volume': [300.00, 270.00, 255.00, 245.00, 235.00, 228.00, 222.00, 215.00, 210.00],
                    'magnetization': [0.002, 0.001, -0.002, 0.001, 0.001, 0.001, 0.001, 0.001, 0.001],
                    'enthalpy': []
                }
            }
        }
    }
    
    # Calculate enthalpy for test data
    for compound in testData:
        for magnetism in testData[compound]:
            for data_source in testData[compound][magnetism]:
                data = testData[compound][magnetism][data_source]
                data['enthalpy'] = []
                for i in range(len(data['pressure'])):
                    p = data['pressure'][i]
                    e = data['energy'][i]
                    v = data['volume'][i]
                    enthalpy = e + p * v * 6.241509e-3  # H = E + P*V
                    data['enthalpy'].append(enthalpy)
    
    # Plot test data
    pEplot(testData, properties=['energy', 'volume', 'magnetization', 'enthalpy'], 
           combine_magnetism=True, save_dir='test_plots')

if __name__ == '__main__':
    # Define file paths and labels
    filenames = {
        "energy_volume_magnetization_66.txt": "Data#66",
        "energy_volume_magnetization_33.txt": "Data#33"
        # Add more files as needed: "filename.txt": "Label"
    }
    
    # Read data from files
    plotData = pERead(filenames)
    
    # Plot all properties
    pEplot(plotData, properties=['energy', 'volume', 'magnetization', 'enthalpy'], 
           combine_magnetism=True, save_dir='plots')

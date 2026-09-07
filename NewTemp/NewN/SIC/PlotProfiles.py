import argparse
import glob
import re
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt

def main():
  figLi, axesLi = plt.subplots(figsize=(16, 4.5))
  figSalt, axesSalt = plt.subplots(figsize=(16, 4.5))
  figCharge, axesCharge = plt.subplots(figsize=(16, 4.5))
  figCp, axesCp = plt.subplots(figsize=(16, 4.5))
  figCn, axesCn = plt.subplots(figsize=(16, 4.5))
  figCe, axesCe = plt.subplots(1, 2, figsize=(16, 4.5))
  figCi, axesCi = plt.subplots(1, 2, figsize=(16, 4.5))
  figPsi1, axesPsi1 = plt.subplots(figsize=(16, 4.5))
  figPsi2, axesPsi2 = plt.subplots(1, 3, figsize=(16, 4.5))
  suffixes = ["0000", "0005", "0010", "0015", "0020", "0025", "0030", "0035"]#, "0040", "0050"]
  colors = ["#000000", "#56B4E9", "#0072B2", "#009E73", "#F0E442", "#E69F00", "#D55E00", "#CC79A7", "#999999"]
  for i, s in enumerate(suffixes):
      dfci = pd.read_csv(f'Charge_out_ci_sample_{s}.csv')
      dfce = pd.read_csv(f'Charge_out_rho_sample_{s}.csv')
      dfcp = pd.read_csv(f'Charge_out_cp_sample_{s}.csv')
      dfcn = pd.read_csv(f'Charge_out_cn_sample_{s}.csv')
      dfpsiM = pd.read_csv(f'Charge_out_psi_sample_{s}.csv')
      dfpsiE = pd.read_csv(f'Charge_out_psi_e_sample_{s}.csv')

      ciMskL = dfci['x']<=0
      ciMskR = dfci['x']>=1
      dfciL = dfci[ciMskL]
      dfciR = dfci[ciMskR]
      dfceL = dfce[ciMskL]
      dfceR = dfce[ciMskR]
      psiEMskL = dfpsiE['x']<=0
      psiEMskR = dfpsiE['x']>=1
      dfpsiL = dfpsiE[psiEMskL]
      dfpsiR = dfpsiE[psiEMskR]
     
      L = r'$\hat{t} = $' + suffixes[i]

      axesLi.plot(dfciL['x'], dfciL['ci'], '.', color=colors[i])
      axesLi.plot( dfcp['x'],  dfcp['cp'], '.', color=colors[i], label=L) 
      axesLi.plot(dfciR['x'], dfciR['ci'], '.', color=colors[i])

      axesSalt.plot(dfcp['x'], dfcp['cp']+dfcn['cn'], '.', color=colors[i], label=L)

      axesCharge.plot( dfcp['x'], dfcp['cp']-dfcn['cn'], '.', color=colors[i])
      axesCharge.plot(dfceL['x'],    1.5-dfceL['rho_e'], '.', color=colors[i], label=L)
      axesCharge.plot(dfceR['x'],    1.5-dfceL['rho_e'], '.', color=colors[i])

      axesCp.plot(dfcp['x'], dfcp['cp'], '.', color=colors[i], label=L)
      axesCn.plot(dfcn['x'], dfcn['cn'], '.', color=colors[i], label=L)
      axesCe[0].plot(dfceL['x'], dfceL['rho_e'], '.', color=colors[i])
      axesCe[1].plot(dfceR['x'], dfceR['rho_e'], '.', color=colors[i], label=L)
      axesCi[0].plot(dfciL['x'], dfciL['ci'], '.', color=colors[i])
      axesCi[1].plot(dfciR['x'], dfciR['ci'], '.', color=colors[i], label=L)
      axesPsi1.plot(dfpsiL['x'], dfpsiL['psi_e'], '.', color=colors[i])
      axesPsi1.plot(dfpsiM['x'], dfpsiM['psi'],   '.', color=colors[i], label=L)
      axesPsi1.plot(dfpsiR['x'], dfpsiR['psi_e'], '.', color=colors[i])
      axesPsi2[0].plot(dfpsiL['x'], dfpsiL['psi_e'], '.', color=colors[i])
      axesPsi2[1].plot(dfpsiM['x'], dfpsiM['psi'],   '.', color=colors[i])
      axesPsi2[2].plot(dfpsiR['x'], dfpsiR['psi_e'], '.', color=colors[i], label=L)


  axesLi.set_title("Lithium Profile")
  axesLi.set_xlabel(r"$\hat{x}$")
  axesLi.set_ylabel("Volume Fraction of Lithium")
  axesLi.legend()
  figLi.tight_layout()
  figLi.savefig("ChargeLiProfile.png", dpi=150)
  
  axesSalt.set_title("Salt Profile")
  axesSalt.set_xlabel(r"$\hat{x}$")
  axesSalt.set_ylabel(r"$\phi_+\left(\hat{x},\hat{t}\right)+\phi_-\left(\hat{x},\hat{t}\right)$")
  axesSalt.legend()
  figSalt.tight_layout()
  figSalt.savefig("ChargeSaltProfile.png", dpi=150)
  
  axesCharge.set_title("Charge Profile")
  axesCharge.set_xlabel(r"$\hat{x}$")
  axesCharge.set_ylabel("Volume Fraction of Charge")
  axesCharge.legend()
  figCharge.tight_layout()
  figCharge.savefig("ChargeChargeProfile.png", dpi=150)

  axesCp.set_title("Cation Profile")
  axesCp.set_xlabel(r"$\hat{x}$")
  axesCp.set_ylabel(r'$\phi_+\left(\hat{x}, \hat{t}\right)$')
  axesCp.legend()
  figCp.tight_layout()
  figCp.savefig("Cp.png", dpi=150)

  axesCn.set_title("Anion Profile")
  axesCn.set_xlabel(r"$\hat{x}$")
  axesCn.set_ylabel(r'$\phi_-\left(\hat{x}, \hat{t}\right)$')
  axesCn.legend()
  figCn.tight_layout()
  figCn.savefig("Cn.png", dpi=150)
  
  figCe.suptitle("Intercalated Metal Profile")
  figCe.supxlabel(r"$\hat{x}$")
  axesCe[0].set_ylabel(r"$\frac{\rho_{e_\mathrm{L}}\left(\hat{x},\hat{t}\right)}{\rho_+^o}$")
  axesCe[1].set_ylabel(r"$\frac{\rho_{e_\mathrm{R}}\left(\hat{x},\hat{t}\right)}{\rho_+^o}$")
  axesCe[1].legend()
  figCe.tight_layout()
  figCe.savefig("Ce.png", dpi=150)

  figCi.suptitle("Intercalated Metal Profile")
  figCi.supxlabel(r"$\hat{x}$")
  axesCi[0].set_ylabel(r"$\phi_{i_\mathrm{L}}\left(\hat{x},\hat{t}\right)$")
  axesCi[1].set_ylabel(r"$\phi_{i_\mathrm{R}}\left(\hat{x},\hat{t}\right)$")
  axesCi[1].legend()
  figCi.tight_layout()
  figCi.savefig("Ci.png", dpi=150)

  axesPsi1.set_title("Electrostatic Potential Profile")
  axesPsi1.set_xlabel(r"$\hat{x}$")
  axesPsi1.set_ylabel(r'$\hat{\psi}\left(\hat{x},\hat{t}\right)$')
  axesPsi1.legend()
  figPsi1.tight_layout()
  figPsi1.savefig("Psi1.png", dpi=150)

  figPsi2.suptitle("Electrostatic Potential Profile")
  figPsi2.supxlabel(r"$\hat{x}$")
  axesPsi2[0].set_ylabel(r'$\hat{\psi}_\mathrm{L}\left(\hat{x},\hat{t}\right)$')
  axesPsi2[1].set_ylabel(r'$\hat{\psi}_\mathrm{M}\left(\hat{x},\hat{t}\right)$')
  axesPsi2[2].set_ylabel(r'$\hat{\psi}_\mathrm{R}\left(\hat{x},\hat{t}\right)$')
  axesPsi2[2].legend()
  figPsi2.tight_layout()
  figPsi2.savefig("Psi2.png", dpi=150)

  print(f"Saved profiles")

if __name__ == "__main__":
    main()


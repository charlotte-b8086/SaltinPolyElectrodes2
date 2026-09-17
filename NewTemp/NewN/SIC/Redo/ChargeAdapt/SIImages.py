import argparse
import glob
import re
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt

def main():
  tau = 480.6811909235101
  rhoM =  0.4142271248762551
  rhoP = 6.410860048681629e+28
  figLi, axesLi = plt.subplots(figsize=(16, 4.5))
  figCharge, axesCharge = plt.subplots(figsize=(16, 4.5))
  figCm, axesCm = plt.subplots(figsize=(16, 4.5))
  suffixes = ["0000", "0005", "0010", "0015", "0020", "0025", "0030", "0035"]
  colors = ["#000000", "#56B4E9", "#0072B2", "#009E73", "#F0E442", "#E69F00", "#D55E00", "#CC79A7", "#999999"]
  for i, s in enumerate(suffixes):
      dfci = pd.read_csv(f'Charge_out_ci_sample_{s}.csv')
      dfce = pd.read_csv(f'Charge_out_rho_sample_{s}.csv')
      dfcp = pd.read_csv(f'Charge_out_cp_sample_{s}.csv')
      dfcm = pd.read_csv(f'Charge_out_cm_sample_{s}.csv')

      ciMskL = dfci['x']<=0
      ciMskR = dfci['x']>=1
      dfciL = dfci[ciMskL]
      dfciR = dfci[ciMskR]
      
      ceMskL = dfce['x']<=0
      ceMskR = dfce['x']>=1
      dfceL = dfce[ceMskL]
      dfceR = dfce[ceMskR]

      L = r'${t} = $' + str(round(tau*int(suffixes[i]))) + ' (seconds)'

      axesLi.plot(dfciL['x'], rhoP*dfciL['ci'], '.', color=colors[i])
      axesLi.plot( dfcp['x'], rhoP*dfcp['cp'], '.', color=colors[i], label=L) 
      axesLi.plot(dfciR['x'], rhoP*dfciR['ci'], '.', color=colors[i])

      axesCharge.plot( dfcp['x'], rhoP*(dfcp['cp']-rhoM*dfcm['cm']), '.', color=colors[i])
      axesCharge.plot(dfceL['x'], rhoP*(1.5-dfceL['rho_e']), '.', color=colors[i], label=L)
      axesCharge.plot(dfceR['x'], rhoP*(1.5-dfceL['rho_e']), '.', color=colors[i])

      axesCm.plot(dfcm['x'], rhoP*rhoM*dfcm['cm'], '.', color=colors[i], label=L)

  axesLi.set_title("Lithium Profile")
  axesLi.set_xlabel(r"${x}$ ($\mu$m)")
  axesLi.set_ylabel(r"""Number Density of Lithium (1/m$^3$)
                     $\{ \rho_{i_\mathrm{L}}(x,t) \text{ for } x < 0,$
                     $\ \rho_+(x,t) \text{ for } 0 < x < 1,$
                     $\ \rho_{i_\mathrm{R}}(x,t) \text{ for } x > 1 \}$""", multialignment='right', labelpad=15 )
  axesLi.legend()
  figLi.tight_layout()
  figLi.savefig("ChargeLiProfile.png", dpi=150)
  
  axesCharge.set_title("Charge Profile")
  axesCharge.set_xlabel(r"${x}$ ($\mu$m)")
  axesCharge.set_ylabel(r"""Number Density of Charge (1/m$^3$)
                     $\{ q_\mathrm{L}-\rho_{e_\mathrm{L}}(x,t) \text{ for } x < 0,$
                     $\ \rho_+(x,t)-\rho_p(x,t) \text{ for } 0 < x < 1,$
                     $\ q_\mathrm{R}-\rho_{e_\mathrm{R}}(x,t) \text{ for } x > 1 \}$""", multialignment='right', labelpad=15 )

  axesCharge.legend()
  figCharge.tight_layout()
  figCharge.savefig("ChargeChargeProfile.png", dpi=150)

  axesCm.set_title("Polymer Profile")
  axesCm.set_xlabel(r"${x}$ ($\mu$m)")
  axesCm.set_ylabel(r'$\rho_p\left({x}, {t}\right)$ (1/m$^3$)')
  axesCm.legend()
  figCm.tight_layout()
  figCm.savefig("Cm.png", dpi=150)

  print(f"Saved profiles")

if __name__ == "__main__":
    main()


"""
Plot (t, v), (t, i_R), and (i_R, v) from Safeguard MOOSE outputs.

Definitions (adjust in CONFIG below if yours differ):
  v(t)   = psi_e_right(t) - psi_e_left(t)   [cell terminal voltage,
           from the main Postprocessor CSV, e.g. Safeguard_out.csv]
  i_R(t) = D_e * rho_ODE evaluated at the requested interface
           (electron reaction-flux "current"), extracted from the
           per-timestep VectorPostprocessor samples, e.g.
           Safeguard_out_rho_gov_sample_0000.csv, ..._0001.csv, ...

Usage:
    python plot_v_iR.py --prefix Safeguard_out --D_e 100 --interface interface0

Requires: pandas, numpy, matplotlib
"""

import argparse
import glob
import re
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt


def get_voltage(prefix):
    """Read the main Postprocessor CSV and compute v(t) = psi_e_right - psi_e_left."""
    df  = pd.read_csv(f"{prefix}.csv")
    df["step"] = np.arange(len(df))
    #df = df[(df["rho_e_left"] > 0) & (df["rho_e_right"] > 0)].reset_index(drop=True)
    t_v = df["time"].values
    step_to_t = dict(zip(df["step"].values, t_v))   # map original step -> time
    v   = np.log(df["rho_e_left"].values/df["rho_e_right"].values) - df["psi_e_left"].values - (-df["psi_e_right"].values)
    return t_v, v, step_to_t

def get_iR(prefix, delta, step_to_t):
    pattern = f"{prefix}_ci_sample_*.csv"
    files = sorted(glob.glob(pattern))
    step_re = re.compile(r"_(\d+)\.csv$")
    steps, iR = [], []
    for f in files:
        step = int(step_re.search(f).group(1))
        if step not in step_to_t:
            continue    # skip samples whose corresponding row got filtered out
        df = pd.read_csv(f)
        rightMsk = df['x']>1.0
        y = df[rightMsk]['ci'].values
        x = df[rightMsk]['x'].values
        steps.append(step)
        iR.append(np.trapezoid(y, x)/delta)
    order = np.argsort(steps)
    steps = np.array(steps)[order]
    iR = np.array(iR)[order]
    t_iR = np.array([step_to_t[s] for s in steps])
    #print(iR)
    return t_iR, iR

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--prefix", default="Charge_out",
                         help="Output file base name (default: Charge_out)")
    parser.add_argument("--prefixD", default="Discharge_out",
                         help="Output file base name (default: Discharge_out)")
    parser.add_argument("--delta", type=float, required=True,
                         help="Electrode thickness used to normalize the ci-integral rate")
    parser.add_argument("--out", default="v_iR_plots.png",
                         help="Output image filename")
    args = parser.parse_args()
 
    t_v , v, step_to_t = get_voltage(args.prefix)
    t_iR, iR           = get_iR(args.prefix, args.delta, step_to_t)
    #print(iR)
    t_vD , vD, step_to_tD = get_voltage(args.prefixD)
    t_iRD, iRD           = get_iR(args.prefixD, args.delta, step_to_tD)
    print(vD[0:3], v[-3:])
    print(iRD[0:3], iR[-3:])
    args = parser.parse_args()

### Troubleshooting
    df  = pd.read_csv(f"Discharge_out.csv")
    tTemp = df["time"].values
    rhoL = df["rho_e_left"].values
    rhoR = df["rho_e_right"].values
    figT, axesT = plt.subplots(1, 2, figsize=(16, 4.5))
    axesT[0].plot(tTemp, rhoL)
    axesT[1].plot(tTemp, rhoR)
    
    figT.tight_layout()
    figT.savefig("ElectronElectrodeExternalCircuitValues", dpi=150)
    
    dfcp  = pd.read_csv(f"Charge_out_cp_sample_0025.csv")
    dfcn  = pd.read_csv(f"Charge_out_cn_sample_0025.csv")
    dfcm  = pd.read_csv(f"Charge_out_cm_sample_0025.csv")

    figT2, axesT2 = plt.subplots(1, 3, figsize=(16, 4.5))
    axesT2[0].plot(dfcp['x'], dfcp['cp'], '.')
    axesT2[0].set_ylabel(r'$\phi_+$')
    axesT2[1].plot(dfcn['x'], dfcn['cn'], '.')
    axesT2[1].set_ylabel(r"$\phi_-$")
    axesT2[2].plot(dfcm['x'], dfcm['cm'], '.')
    axesT2[2].set_ylabel(r"$\phi_p$")
    figT2.supxlabel(r"$\hat{x}$")
    figT2.tight_layout()
    figT2.savefig("ElectrolyteSpeciesMidPointProfile", dpi=150)
    
    dfci  = pd.read_csv(f"Charge_out_ci_sample_0025.csv")
    dfce  = pd.read_csv(f"Charge_out_rho_sample_0025.csv")
    ciMskL = dfci['x']<=0
    ciMskR = dfci['x']>=1
    dfciL = dfci[ciMskL]
    dfciR = dfci[ciMskR]
    ceMskL = dfce['x']<=0
    ceMskR = dfce['x']>=1
    dfceL = dfce[ceMskL]
    dfceR = dfce[ceMskR]
    
    figT3, axesT3 = plt.subplots(2, 2, figsize=(16, 4.5))
    axesT3[0, 0].plot(dfciL['x'], dfciL['ci'], '.')
    axesT3[0, 0].set_ylabel(r"$\phi_{i_\mathrm{L}}$")
    axesT3[0, 1].plot(dfciR['x'], dfciR['ci'], '.')
    axesT3[0, 1].set_ylabel(r"$\phi_{i_\mathrm{R}}$")
    axesT3[1, 0].plot(dfceL['x'], dfceL['rho_e'], '.')
    axesT3[1, 0].set_ylabel(r"$\frac{\rho_{e_\mathrm{L}}}{\rho_+^o}$")
    axesT3[1, 1].plot(dfceR['x'], dfceR['rho_e'], '.')
    axesT3[1, 1].set_ylabel(r"$\frac{\rho_{e_\mathrm{R}}}{\rho_+^o}$")
    figT3.supxlabel(r"$\hat{x}$")
    figT3.tight_layout()
    figT3.savefig("ElectrodeSpeciesMidPointProfile", dpi=150)
    
    dfpsiM = pd.read_csv(f"Charge_out_psi_sample_0025.csv")
    dfpsiE = pd.read_csv(f"Charge_out_psi_e_sample_0025.csv")
    psiLMsk = dfpsiE['x']<=0
    psiRMsk = dfpsiE['x']>=1
    dfpsiL = dfpsiE[psiLMsk]
    dfpsiR = dfpsiE[psiRMsk]

    figT4, axesT4 = plt.subplots(1, 3, figsize=(16, 4.5))
    axesT4[1].plot(dfpsiM['x'], dfpsiM['psi'], '.')
    axesT4[1].set_ylabel(r"$\hat{\psi}_\mathrm{M}$")
    axesT4[0].plot(dfpsiL['x'], dfpsiL['psi_e'], '.')
    axesT4[0].set_ylabel(r"$\hat{\psi}_\mathrm{L}$")
    axesT4[2].plot(dfpsiR['x'], dfpsiR['psi_e'], '.')
    axesT4[2].set_ylabel(r"$\hat{\psi}_\mathrm{R}$")
    figT4.supxlabel(r"$\hat{x}$")
    figT4.tight_layout()
    figT4.savefig("PsiMidPointProfile", dpi=150)

    print(f"Saved temp")

    fig, axes = plt.subplots(2, 3, figsize=(16, 4.5))

    axes[0, 0].plot(t_v[0:26], v[0:26], color="tab:blue")
    axes[0, 0].set_xlabel(r"$\hat{t}$")
    axes[0, 0].set_ylabel(
    r'$\ln\left(\frac{\rho_{e_\mathrm{L}}}{\rho_+^o}\right) -'
    r' \frac{e\psi_\mathrm{L}}{k_BT}|_{-\delta}-'
    r' \left[\ln\left(\frac{\rho_{e_\mathrm{R}}}{\rho_+^o}\right)'
    r' -\frac{e\psi_\mathrm{R}}{k_BT}\right]|_{1+\delta}$'
)
    axes[0, 0].set_title("Voltage vs Time")

    axes[0, 1].plot(t_iR[0:26], iR[0:26], color="tab:orange")
    axes[0, 1].set_xlabel(r"$\hat{t}$")
    axes[0, 1].set_ylabel(
    r'$\frac{\int_1^{1+\delta}\phi_{i_\mathrm{R}}\left(\hat{x},\hat{t}\right)'
    r' \, \mathrm{d}\hat{x}}{\int_1^{1+\delta}\phi_{i_\mathrm{R}}'
    r'\left(\hat{x},\hat{t}\right)+\phi_{v_\mathrm{R}}\left(\hat{x},\hat{t}\right)'
    r'\,\mathrm{d}\hat{x}}$'
)
    #print(iR)
    axes[0, 1].set_title(f"Utilization vs Time")

    axes[0, 2].plot(iR[0:26], v[0:26], color="tab:green", marker="o", markersize=2)
    axes[0, 2].set_xlabel(
    r'$\frac{\int_1^{1+\delta}\phi_{i_\mathrm{R}}\left(\hat{x},\hat{t}\right)'
    r' \, \mathrm{d}\hat{x}}{\int_1^{1+\delta}\phi_{i_\mathrm{R}}'
    r'\left(\hat{x},\hat{t}\right)+\phi_{v_\mathrm{R}}\left(\hat{x},\hat{t}\right)'
    r'\,\mathrm{d}\hat{x}}$'
)
    axes[0, 2].set_ylabel(
    r'$\ln\left(\frac{\rho_{e_\mathrm{L}}}{\rho_+^o}\right) -'
    r' \frac{e\psi_\mathrm{L}}{k_BT}|_{-\delta}-'
    r' \left[\ln\left(\frac{\rho_{e_\mathrm{R}}}{\rho_+^o}\right)'
    r' -\frac{e\psi_\mathrm{R}}{k_BT}\right]|_{1+\delta}$'
)

    axes[0, 2].set_title("Voltage vs Utilization")
 
    axes[1, 0].plot(t_vD[0:26], vD[0:26], color="tab:blue")
    axes[1, 0].set_xlabel(r"$\hat{t}$")
    axes[1, 0].set_ylabel(
    r'$\ln\left(\frac{\rho_{e_\mathrm{L}}}{\rho_+^o}\right) -'
    r' \frac{e\psi_\mathrm{L}}{k_BT}|_{-\delta}-'
    r' \left[\ln\left(\frac{\rho_{e_\mathrm{R}}}{\rho_+^o}\right)'
    r' -\frac{e\psi_\mathrm{R}}{k_BT}\right]|_{1+\delta}$'
)
    axes[1, 0].set_title("Voltage vs Time")

    axes[1, 1].plot(t_iRD[0:26], iRD[0:26], color="tab:orange")
    axes[1, 1].set_xlabel(r"$\hat{t}$")
    axes[1, 1].set_ylabel(
    r'$\frac{\int_1^{1+\delta}\phi_{i_\mathrm{R}}\left(\hat{x},\hat{t}\right)'
    r' \, \mathrm{d}\hat{x}}{\int_1^{1+\delta}\phi_{i_\mathrm{R}}'
    r'\left(\hat{x},\hat{t}\right)+\phi_{v_\mathrm{R}}\left(\hat{x},\hat{t}\right)'
    r'\,\mathrm{d}\hat{x}}$'
)
    axes[1, 1].set_title(f"Utilization vs Time")

    axes[1, 2].plot(iRD[0:26], vD[0:26], color="tab:green", marker="o", markersize=2)
    axes[1, 2].set_xlabel(
    r'$\frac{\int_1^{1+\delta}\phi_{i_\mathrm{R}}\left(\hat{x},\hat{t}\right)'
    r' \, \mathrm{d}\hat{x}}{\int_1^{1+\delta}\phi_{i_\mathrm{R}}'
    r'\left(\hat{x},\hat{t}\right)+\phi_{v_\mathrm{R}}\left(\hat{x},\hat{t}\right)'
    r'\,\mathrm{d}\hat{x}}$'
)
    axes[1, 2].set_ylabel(
    r'$\ln\left(\frac{\rho_{e_\mathrm{L}}}{\rho_+^o}\right) -'
    r' \frac{e\psi_\mathrm{L}}{k_BT}|_{-\delta}-'
    r' \left[\ln\left(\frac{\rho_{e_\mathrm{R}}}{\rho_+^o}\right)'
    r' -\frac{e\psi_\mathrm{R}}{k_BT}\right]|_{1+\delta}$'
)

    axes[1, 2].set_title("Voltage vs Utilization")


    fig.tight_layout()
    fig.savefig(args.out, dpi=150)
    
    figV, axesV = plt.subplots(figsize=(16, 4.5))
    axesV.plot(t_v[0:26], v[0:26], color='k', marker='o', markersize=2, label="Charge")
    axesV.plot(max(t_v[0:26])+t_vD[0:26], vD[0:26], color="tab:blue", marker='o', markersize=2, label="Discharge")
    axesV.set_xlabel(r"$\hat{t}$")
    axesV.set_ylabel(
    r'$\ln\left(\frac{\rho_{e_\mathrm{L}}}{\rho_+^o}\right) -'
    r' \frac{e\psi_\mathrm{L}}{k_BT}|_{-\delta}-'
    r' \left[\ln\left(\frac{\rho_{e_\mathrm{R}}}{\rho_+^o}\right)'
    r' -\frac{e\psi_\mathrm{R}}{k_BT}\right]|_{1+\delta}$'
)
    axesV.set_title("Voltage vs Time")
    axesV.legend()
    figV.tight_layout()
    figV.savefig("V(t)Troubleshoot", dpi=150)

    figU, axesU = plt.subplots(figsize=(16, 4.5))
    print('hey')
    print(t_v[0:26], iR[0:26])
    axesU.plot(t_v[0:26], iR[0:26], color='k', marker='o', markersize=2, label="Charge")
    axesU.plot(max(t_v[0:26])+t_vD[0:26], iRD[0:26], color="tab:blue", marker='o', markersize=2, label="Discharge")
    axesU.set_xlabel(r"$\hat{t}$")
    axesU.set_ylabel(
    r'$\frac{\int_1^{1+\delta}\phi_{i_\mathrm{R}}\left(\hat{x},\hat{t}\right)'
    r' \, \mathrm{d}\hat{x}}{\int_1^{1+\delta}\phi_{i_\mathrm{R}}'
    r'\left(\hat{x},\hat{t}\right)+\phi_{v_\mathrm{R}}\left(\hat{x},\hat{t}\right)'
    r'\,\mathrm{d}\hat{x}}$'
)
    axesU.set_title("Utilization vs Time")
    axesU.legend()
    figU.tight_layout()
    figU.savefig("U(t)TroubleshootAgain", dpi=150)

    print(f"Saved {args.out}")

if __name__ == "__main__":
    main()


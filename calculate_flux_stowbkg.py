from xspec import *
import argparse

def parseArguments():
    parser = argparse.ArgumentParser()
    parser.add_argument('model_folder', help='[acispback_<model_folder>] mkacispback output directory', type=str)
    parser.add_argument('-e','--energy', default='None', nargs='+',\
        help='the energy range that you are interested in e.g.; "0.6 2.0"', type=str) #--energy '0.6 2.0' '0.6 7.0'
    args = parser.parse_args()
    return args


def main():
    args = parseArguments()

    AllModels.lmod("acispback_pkg", f"./acispback_{args.model_folder}")
    m1 = Model('acispback')

    with open(f"stowed_bkg_flux_{args.model_folder}.txt", 'w') as f:
        f.write('# erg/cm^2/s,err,err,photons,err,err\n')
        for energy_range in args.energy:
            AllModels.calcFlux(energy_range)
            flux1 = m1.flux
            f.write(f'# energy: {energy_range} keV\n')
            f.write(','.join(str(i) for i in flux1)+' #particle background\n')


if __name__ == "__main__":
    main()
## run through pymol, eg.:
## pymol -qc mutate.py 1god A/94/ ASN

from pymol import cmd
import sys

pdb, selection, mutant = sys.argv[-3:]
cmd.wizard("mutagenesis")
cmd.fetch(pdb)
cmd.refresh_wizard()
cmd.get_wizard().do_select(selection)
cmd.get_wizard().set_mode(mutant)
cmd.get_wizard().apply()
cmd.set_wizard()
cmd.save("%s_m.pdb" % pdb, pdb)
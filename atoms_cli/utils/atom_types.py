from atoms_core.entities.atom_type import AtomType


atom_types = {
    "all": -1,
    "chroot": AtomType.ATOM_CHROOT, 
    "container": AtomType.DISTROBOX_CONTAINER
}

str_atom_types = ", ".join(atom_types.keys())

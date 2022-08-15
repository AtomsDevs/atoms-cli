def emojify_atom_name(atom: "Atom") -> str:
    if atom.is_distrobox_container:
        return "🐳 {}".format(atom.name)
    else:
        return "⚛️  {}".format(atom.name)
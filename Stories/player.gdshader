shader_type canvas_item;

void fragment() {
    // On récupère la texture combinée de toutes les bulles à l'intérieur du groupe
    vec4 mask = texture(TEXTURE, UV);

    // On définit un seuil : si le gris est plus sombre que 0.2, on le supprime
    // Si c'est plus clair, on le transforme en blanc pur opaque.
    // Cela crée la fusion "propre" (effet Metaball)
    float alpha = smoothstep(0.2, 0.3, mask.a);

    // On affiche du blanc pur là où le masque est présent
    COLOR = vec4(1.0, 1.0, 1.0, alpha);
}
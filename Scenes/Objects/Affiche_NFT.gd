extends Area2D

# "@export_multiline" crée un champ de texte modifiable dans l'inspecteur.
@export_multiline var mon_texte_personnalise : String = "C'est une vieille affiche de recrutement... Le visage est effacé."

# Cette fonction est appelée automatiquement par le RayCast du joueur !
func on_interact():
	# On utilise ton super gestionnaire de dialogue global !
	if DialogueManager:
		DialogueManager.afficher_texte(mon_texte_personnalise)

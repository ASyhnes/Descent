shader_type particles;

// --- PARAMÈTRES (Visibles dans l'Inspecteur Godot) ---
uniform vec2 target_pos;
uniform float springiness = 1.0; // (la force du ressort) : Plus elle est haute, plus les particules reviennent vite vers la cible.
uniform float damping = 1000.0;      // Freinage / Amortissement : (l'amortissement) : C'est la force de friction. Plus elle est haute, plus elle "freine" les particules pour les empêcher de dépasser la cible.
uniform float randomness = 5; // Force du frétillement
uniform float cloud_spread = 60.0; // Rayon d'apparition max
uniform float particle_scale = 0.5; // Taille visuelle des particules
uniform float fade_distance = 40.0; // Distance où la particule devient 100% invisible

// Outil mathématique pour générer du hasard propre à chaque particule
float rand(vec2 co){
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

void start() {
    // 1. Initialisation de la matrice (taille et rotation normales)
    TRANSFORM = mat4(1.0);

    // 2. Application de l'échelle (la taille de ta particule)
    TRANSFORM[0][0] = particle_scale;
    TRANSFORM[1][1] = particle_scale;

    // 3. Couleur de base opaque
    COLOR = vec4(1.0);

    // 4. Spawn en cercle régulier autour de la position cible
    float angle = rand(vec2(float(NUMBER), 1.0)) * 2.0 * PI;
    float radius = sqrt(rand(vec2(float(NUMBER), 2.0))) * cloud_spread;

    float rx = cos(angle) * radius;
    float ry = sin(angle) * radius;

    TRANSFORM[3].xy = target_pos + vec2(rx, ry);
}

void process() {
    // 1. Calcul de la distance exacte entre la particule et la cible
    vec2 displacement = TRANSFORM[3].xy - target_pos;

    // 2. Physique : L'élastique + le frein
    vec2 spring_force = (-springiness * displacement) - (damping * VELOCITY.xy);

    // 3. Vent / Chaos : frétillement aléatoire
    float noise_x = (rand(vec2(float(NUMBER), TIME)) - 0.5) * randomness;
    float noise_y = (rand(vec2(TIME, float(NUMBER))) - 0.5) * randomness;
    vec2 chaos = vec2(noise_x, noise_y);

    // 4. Application du mouvement global
    VELOCITY.xy += (spring_force + chaos) * DELTA;

    // 5. --- LE DÉGRADÉ DE TRANSPARENCE (Fade) ---
    float current_distance = length(displacement);

    // On force l'alpha à baisser linéairement en s'éloignant du centre.
    // Si current_distance dépasse fade_distance, l'alpha tombe à 0.0 (invisible).
    float alpha = 1.0 - clamp(current_distance / fade_distance, 0.0, 1.0);

    COLOR.a = alpha;
}
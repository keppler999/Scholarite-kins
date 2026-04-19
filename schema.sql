-- ==========================================
-- SCHOLARITE - SCHEMA OFFICIEL DE LA BASE DE DONNÉES
-- Version : 1.0.2 (Intégration Complète)
-- ==========================================

-- 1. PÔLE STRUCTURE (LE SQUELETTE)
CREATE TABLE IF NOT EXISTS annees_scolaires (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    libelle TEXT NOT NULL, -- ex: 2025-2026
    statut TEXT DEFAULT 'OUVERTE',
    date_creation TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS options (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nom TEXT NOT NULL -- ex: Électricité, Commerciale, Sociale
);

CREATE TABLE IF NOT EXISTS classes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nom TEXT NOT NULL,
    option_id UUID REFERENCES options(id),
    niveau INT -- ex: 1, 2, 3 (pour 3e Électricité)
);

-- 2. PÔLE UTILISATEURS & SÉCURITÉ
CREATE TABLE IF NOT EXISTS jetons_acces (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code_jeton TEXT UNIQUE NOT NULL,
    module_cible TEXT CHECK (module_cible IN ('PROMOTEUR', 'COMPTABLE', 'PROF', 'DE')),
    nom_destinataire TEXT,
    statut TEXT DEFAULT 'DISPONIBLE',
    cree_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. PÔLE ÉDUCATIF (LE CASIER VIRTUEL & PERFORMANCE)
CREATE TABLE IF NOT EXISTS eleves (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    matricule TEXT UNIQUE NOT NULL,
    nom TEXT NOT NULL,
    postnom TEXT,
    prenom TEXT,
    genre CHAR(1),
    date_naissance DATE,
    photo_url TEXT,
    classe_id UUID REFERENCES classes(id),
    statut_discipline TEXT DEFAULT 'VERT', -- VERT (Bon), ORANGE (Averti), ROUGE (Effraction)
    etat_eleve TEXT DEFAULT 'ACTIF', -- ACTIF, ABANDON, RENVOYE
    cree_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS professeurs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nom_complet TEXT NOT NULL,
    grade_direction TEXT DEFAULT 'BON', -- BON, TRES BON, EXCELLENT, TRES EXCELLENT
    contact TEXT
);

CREATE TABLE IF NOT EXISTS cours (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nom_cours TEXT NOT NULL,
    coefficient INT DEFAULT 1
);

CREATE TABLE IF NOT EXISTS horaires (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    classe_id UUID REFERENCES classes(id),
    prof_id UUID REFERENCES professeurs(id),
    cours_id UUID REFERENCES cours(id),
    jour TEXT,
    heure_debut TIME,
    heure_fin TIME
);

CREATE TABLE IF NOT EXISTS notes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    eleve_id UUID REFERENCES eleves(id),
    cours_id UUID REFERENCES cours(id),
    valeur_note DECIMAL(5,2) NOT NULL,
    periode TEXT, -- EXAMEN 1, PERIODE 2, etc.
    saisi_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS incidents_discipline (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    eleve_id UUID REFERENCES eleves(id),
    titre_incident TEXT, -- ex: "Bagarre dans la cour"
    description TEXT,
    date_incident DATE DEFAULT CURRENT_DATE,
    gravite TEXT -- ORANGE ou ROUGE
);

-- 4. PÔLE FINANCE (LA CAISSE)
CREATE TABLE IF NOT EXISTS finances (
    id bigserial PRIMARY KEY,
    eleve_id UUID REFERENCES eleves(id),
    nom_eleve TEXT, -- Doublon pour sécurité de lecture rapide
    montant_paye NUMERIC NOT NULL,
    motif_paiement TEXT, -- ex: Minerval, Frais techniques
    date_paiement TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 5. ÉVÉNEMENTS (LE PROGRAMME)
CREATE TABLE IF NOT EXISTS programme_scolaire (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    titre_event TEXT NOT NULL,
    description TEXT,
    date_debut DATE,
    nombre_jours INT DEFAULT 1,
    type_event TEXT -- TEST_GENERAL, EXAMEN, SPORT, SORTIE
);

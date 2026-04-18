-- ==========================================
-- SCHOLARITE - SCRIPT DE FONDATION SQL
-- ==========================================

-- 1. TABLE DES UTILISATEURS (Comptes réels)
CREATE TABLE utilisateurs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nom_complet TEXT NOT NULL,
    username TEXT UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,
    role TEXT CHECK (role IN ('DE', 'PROF', 'COMPTABLE', 'PROMOTEUR')),
    cree_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. TABLE DES JETONS D'ACCÈS (La clé de ton système)
CREATE TABLE jetons_acces (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code_jeton TEXT UNIQUE NOT NULL,
    module_cible TEXT CHECK (module_cible IN ('PROF', 'COMPTABLE', 'PROMOTEUR')),
    nom_destinataire TEXT,
    statut TEXT DEFAULT 'DISPONIBLE' CHECK (statut IN ('DISPONIBLE', 'UTILISE', 'EXPIRE')),
    cree_par UUID REFERENCES utilisateurs(id),
    cree_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. TABLE DES ÉLÈVES (Le Casier Central)
CREATE TABLE eleves (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    matricule TEXT UNIQUE NOT NULL,
    nom TEXT NOT NULL,
    postnom TEXT,
    prenom TEXT,
    genre CHAR(1),
    date_naissance DATE,
    statut_paiement TEXT DEFAULT 'NON_SOLVABLE',
    moyenne_conduite DECIMAL(4,2) DEFAULT 20.00,
    cree_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 4. TABLE DES NOTES (Lien Prof -> Élève)
CREATE TABLE notes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    eleve_id UUID REFERENCES eleves(id),
    cours_nom TEXT NOT NULL,
    valeur_note DECIMAL(5,2) NOT NULL,
    periode TEXT, -- ex: T1, T2, T3
    saisi_par UUID REFERENCES utilisateurs(id),
    saisi_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 5. TABLE DES FINANCES (Lien Comptable -> Élève)
CREATE TABLE paiements (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    eleve_id UUID REFERENCES eleves(id),
    montant DECIMAL(10,2) NOT NULL,
    type_paiement TEXT DEFAULT 'CASH',
    numero_recu SERIAL,
    comptable_id UUID REFERENCES utilisateurs(id),
    date_paiement TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Scholarite Platinum | Système Unifié</title>
    
    <script src="https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf/2.5.1/jspdf.umd.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf-autotable/3.5.25/jspdf.plugin.autotable.min.js"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Inter:wght@300;400;600;700;800&family=JetBrains+Mono&display=swap');

        :root {
            --primary: #3B82F6; --compta: #B45309; --dir: #8B5CF6;
            --bg: #020617; --panel: #0F172A; --border: rgba(255, 255, 255, 0.05);
            --success: #10B981; --danger: #EF4444;
        }

        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Inter', sans-serif; background: var(--bg); color: white; display: flex; height: 100vh; overflow: hidden; }

        /* --- DASHBOARD UI --- */
        .sidebar { width: 280px; background: #000; border-right: 1px solid var(--border); padding: 25px; display: flex; flex-direction: column; }
        .main-view { flex-grow: 1; padding: 30px; overflow-y: auto; }
        
        .nav-link { padding: 12px; border-radius: 12px; color: #64748B; cursor: pointer; display: flex; align-items: center; gap: 12px; margin-bottom: 5px; transition: 0.3s; }
        .nav-link.active { background: rgba(59, 130, 246, 0.1); color: var(--primary); }
        .nav-link:hover { background: rgba(255,255,255,0.05); }

        .stat-grid { display: grid; grid-template-columns: repeat(4, 1fr); gap: 20px; margin-bottom: 30px; }
        .stat-card { background: var(--panel); padding: 20px; border-radius: 20px; border: 1px solid var(--border); }
        .stat-card h3 { font-family: 'JetBrains Mono'; font-size: 22px; margin-top: 8px; }

        .workspace { background: var(--panel); border-radius: 25px; border: 1px solid var(--border); padding: 25px; min-height: 400px; }
        
        table { width: 100%; border-collapse: collapse; margin-top: 20px; }
        th { text-align: left; padding: 12px; color: #64748B; font-size: 11px; text-transform: uppercase; border-bottom: 1px solid var(--border); }
        td { padding: 15px 12px; border-bottom: 1px solid rgba(255,255,255,0.02); font-size: 14px; }

        /* --- BUTTONS --- */
        .btn { padding: 10px 20px; border-radius: 10px; border: none; font-weight: 700; cursor: pointer; transition: 0.2s; font-size: 12px; }
        .btn-compta { background: var(--compta); color: white; }
        .btn-sync { background: var(--primary); color: white; }

        /* --- MODALS --- */
        .modal-overlay { position: fixed; inset: 0; background: rgba(0,0,0,0.8); backdrop-filter: blur(5px); display: none; justify-content: center; align-items: center; z-index: 100; }
        .modal-box { background: var(--panel); padding: 35px; border-radius: 25px; width: 450px; border: 1px solid var(--border); }
        
        #toast { position: fixed; bottom: 20px; right: 20px; background: var(--success); color: white; padding: 15px 25px; border-radius: 10px; display: none; z-index: 200; }
    </style>
</head>
<body>

    <div id="toast">Opération réussie !</div>

    <aside class="sidebar">
        <div style="margin-bottom: 40px; display: flex; align-items: center; gap: 12px;">
            <div style="width: 42px; height: 42px; background: var(--primary); border-radius: 12px; display: flex; align-items: center; justify-content: center; font-weight: 900; font-size: 20px;">S</div>
            <div><h2 style="font-size: 16px;">SCHOLARITE</h2><small style="color: var(--success); font-weight: 800;">PLATINUM v1.0.2</small></div>
        </div>

        <div class="nav-link active" onclick="loadModule('compta')"><i class="fa-solid fa-wallet"></i> Finance & Caisse</div>
        <div class="nav-link" onclick="loadModule('pedagogie')"><i class="fa-solid fa-chalkboard-user"></i> Pédagogie</div>
        <div class="nav-link" onclick="loadModule('direction')"><i class="fa-solid fa-user-shield"></i> Direction</div>
        <div class="nav-link" onclick="loadModule('discipline')"><i class="fa-solid fa-scale-balanced"></i> Discipline</div>

        <div style="margin-top: auto; padding: 15px; background: rgba(255,255,255,0.03); border-radius: 15px;">
            <small style="color: #64748B;">BDD STATUS</small>
            <p id="db-status" style="font-size: 12px; margin-top: 5px;"><i class="fa-solid fa-circle-dot" style="color: var(--danger)"></i> Déconnecté</p>
        </div>
    </aside>

    <main class="main-view">
        <header style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 30px;">
            <h1 id="module-title">Tableau de Bord</h1>
            <button class="btn btn-sync" onclick="refreshAll()"><i class="fa-solid fa-arrows-rotate"></i> Synchroniser</button>
        </header>

        <div class="stat-grid">
            <div class="stat-card"><small>CAISSE JOUR</small><h3 id="stat-caisse">0.00 $</h3></div>
            <div class="stat-card"><small>PRÉSENCE GLOBALE</small><h3 id="stat-pres">0%</h3></div>
            <div class="stat-card"><small>COTES VALIDÉES</small><h3 id="stat-notes">0%</h3></div>
            <div class="stat-card"><small>ALERTE DISCIPLINE</small><h3 id="stat-disc" style="color:var(--danger)">0</h3></div>
        </div>

        <section class="workspace">
            <div id="module-content">
                </div>
        </section>
    </main>

    <div class="modal-overlay" id="pay-modal">
        <div class="modal-box">
            <h2 style="margin-bottom: 20px;">Encaisser Frais</h2>
            <div style="margin-bottom: 15px;">
                <label style="font-size: 12px; color: #64748B;">ÉLÈVE</label>
                <select id="pay-student-list" style="width: 100%; padding: 12px; background: #000; color: white; border-radius: 10px; border: 1px solid var(--border); margin-top: 5px;"></select>
            </div>
            <div style="margin-bottom: 20px;">
                <label style="font-size: 12px; color: #64748B;">MONTANT (USD)</label>
                <input type="number" id="pay-amount" placeholder="0.00" style="width: 100%; padding: 12px; background: #000; color: white; border-radius: 10px; border: 1px solid var(--border); margin-top: 5px; font-size: 20px;">
            </div>
            <div style="display: flex; gap: 10px;">
                <button class="btn btn-compta" style="flex-grow: 1;" onclick="submitPayment()">VALIDER PAIEMENT</button>
                <button class="btn" style="background: #1E293B; color: white;" onclick="closeModal()">ANNULER</button>
            </div>
        </div>
    </div>

    <script>
        // --- CONFIGURATION SUPABASE (PROJET PLATINUM) ---
        const SB_URL = "https://chpydetdbfugwwhsvgin.supabase.co"; 
        const SB_KEY = "sb_publishable_G3rNGdnIihPNVfaLj1C4VQ_1TUBFh_z"; 
        const _supabase = supabase.createClient(SB_URL, SB_KEY);

        let currentEleves = [];
        let currentModule = 'compta';

        window.onload = async () => {
            const connected = await checkDB();
            if(connected) {
                document.getElementById('db-status').innerHTML = '<i class="fa-solid fa-circle-dot" style="color: var(--success)"></i> Connecté Supabase';
                await refreshAll();
            }
            loadModule('compta');
        };

        async function checkDB() {
            try {
                const { error } = await _supabase.from('students').select('id').limit(1);
                return !error;
            } catch(e) { return false; }
        }

        async function refreshAll() {
            const { data: eleves } = await _supabase.from('students').select('*').order('name', { ascending: true });
            currentEleves = eleves || [];
            
            // Calcul Caisse
            const { data: finances } = await _supabase.from('finances').select('montant_paye');
            const total = finances?.reduce((sum, f) => sum + parseFloat(f.montant_paye), 0) || 0;
            document.getElementById('stat-caisse').innerText = total.toFixed(2) + " $";

            // Calcul Notes (Simulé sur le scellement)
            const { data: evals } = await _supabase.from('evaluations').select('is_sealed');
            const sealed = evals?.filter(e => e.is_sealed).length || 0;
            const percent = evals?.length > 0 ? Math.round((sealed / evals.length) * 100) : 0;
            document.getElementById('stat-notes').innerText = percent + "%";

            updateModuleUI();
        }

        function loadModule(type) {
            currentModule = type;
            const content = document.getElementById('module-content');
            const title = document.getElementById('module-title');
            
            document.querySelectorAll('.nav-link').forEach(l => l.classList.remove('active'));
            const activeLink = Array.from(document.querySelectorAll('.nav-link')).find(l => l.innerText.toLowerCase().includes(type === 'compta' ? 'finance' : type));
            if(activeLink) activeLink.classList.add('active');

            if(type === 'compta') {
                title.innerText = "Gestion Financière";
                content.innerHTML = `
                    <div style="display:flex; justify-content:space-between; align-items:center">
                        <h3>Registre des Paiements (USD)</h3>
                        <button class="btn btn-compta" onclick="openPayModal()"><i class="fa-solid fa-plus"></i> Encaisser Frais</button>
                    </div>
                    <table>
                        <thead><tr><th>ÉLÈVE</th><th>STATUS</th><th>TOTAL PAYÉ</th><th>ACTION</th></tr></thead>
                        <tbody id="compta-body"></tbody>
                    </table>
                `;
                renderCompta();
            } else if(type === 'pedagogie') {
                title.innerText = "Suivi Pédagogique";
                content.innerHTML = `<h3>Soumissions des Professeurs</h3><p style="color:#64748B; margin-top:20px;">Accès aux grilles de cotes en attente de validation...</p>`;
            }
        }

        function renderCompta() {
            const body = document.getElementById('compta-body');
            if(currentEleves.length === 0) {
                body.innerHTML = '<tr><td colspan="4" style="text-align:center">Aucun élève trouvé.</td></tr>';
                return;
            }
            body.innerHTML = currentEleves.map(e => `
                <tr>
                    <td><b>${e.name}</b></td>
                    <td><span style="color:var(--success)">En règle</span></td>
                    <td style="font-family:'JetBrains Mono'; font-weight:800;">${(e.total_paye || 0).toFixed(2)} $</td>
                    <td><button class="btn btn-sync" style="padding:5px 10px" onclick="printReceipt('${e.name}')">📜 Reçu</button></td>
                </tr>
            `).join('');
        }

        function updateModuleUI() {
            if(currentModule === 'compta') renderCompta();
        }

        // --- ACTIONS ---
        function openPayModal() {
            const list = document.getElementById('pay-student-list');
            list.innerHTML = currentEleves.map(e => `<option value="${e.id}">${e.name}</option>`).join('');
            document.getElementById('pay-modal').style.display = 'flex';
        }

        async function submitPayment() {
            const id = document.getElementById('pay-student-list').value;
            const amount = document.getElementById('pay-amount').value;
            const student = currentEleves.find(e => e.id === id);

            if(!amount) return alert("Entrez un montant");

            const { error } = await _supabase.from('finances').insert([
                { eleve_id: id, nom_eleve: student.name, montant_paye: amount, motif_paiement: 'Frais Scolaires' }
            ]);

            if(!error) {
                // Notifier la discipline (Optionnel - Envoie un message au prof via la table de refoulement)
                await _supabase.from('chat_refoulement').insert([{ content: `PAIEMENT: ${student.name} a payé ${amount}$. Accès autorisé.` }]);
                
                showToast("Paiement validé !");
                closeModal();
                refreshAll();
            }
        }

        function closeModal() { document.getElementById('pay-modal').style.display = 'none'; }
        
        function printReceipt(name) {
            const { jsPDF } = window.jspdf;
            const doc = new jsPDF();
            doc.setFontSize(22);
            doc.text("PLATINUM SYSTEM - RECU", 105, 40, { align: 'center' });
            doc.setFontSize(14);
            doc.text(`Élève : ${name}`, 20, 70);
            doc.text(`Date : ${new Date().toLocaleDateString()}`, 20, 80);
            doc.text(`Motif : Frais de Scolarité`, 20, 90);
            doc.text("------------------------------------------", 20, 100);
            doc.text("Signature Caisse", 150, 130);
            doc.save(`Recu_${name}.pdf`);
        }

        function showToast(msg) {
            const t = document.getElementById('toast');
            t.innerText = msg; t.style.display = 'block';
            setTimeout(() => t.style.display = 'none', 3000);
        }
    </script>
</body>
</html>
            

# Recensement des stagiaires : mise en ligne

L'application est composée de deux pages, toutes deux protégées par connexion :

- `index.html` : page de saisie pour les **agents** (enregistrer un stagiaire et son heure de sortie)
- `admin.html` : espace **administrateur** (consultation de toutes les données, modification, suppression, export Excel)

GitHub Pages héberge les pages, mais ne peut pas stocker de données. Les données sont enregistrées dans **Supabase** (service gratuit), ce qui permet de les consulter à distance en temps réel.

## 1. Créer la base de données (Supabase)

1. Créez un compte gratuit sur https://supabase.com puis cliquez sur **New project**.
2. Quand le projet est prêt, ouvrez **SQL Editor > New query**, collez le contenu de `supabase-setup.sql` et cliquez sur **Run**.

## 2. Créer les comptes

1. Ouvrez **Authentication > Users > Add user > Create new user**.
2. Créez un compte pour **chaque personne** (administrateur et agents) avec e-mail et mot de passe, en cochant **Auto Confirm User**.
3. Ouvrez **Authentication > Sign In / Providers** et désactivez **Allow new users to sign up**, pour que personne ne puisse créer de compte seul.

## 3. Désigner l'administrateur

Tous les comptes sont des agents par défaut. Pour donner le rôle administrateur à un compte, ouvrez **SQL Editor > New query**, collez la ligne suivante en remplaçant l'adresse, puis cliquez sur **Run** :

```sql
insert into administrateurs (user_id)
select id from auth.users where email = 'admin@exemple.com';
```

Pour retirer ce rôle plus tard :

```sql
delete from administrateurs
where user_id = (select id from auth.users where email = 'admin@exemple.com');
```

## 4. Relier les pages à Supabase

1. Dans Supabase, ouvrez **Project Settings > API**.
2. Copiez **Project URL** et la clé **anon public**.
3. Collez-les dans `config.js` à la place de `VOTRE-PROJET` et `VOTRE-CLE-ANON-PUBLIQUE`.

N'utilisez jamais la clé `service_role` dans ce fichier.

## 5. Héberger sur GitHub

1. Créez un compte sur https://github.com, puis un nouveau dépôt (par exemple `stagiaires`).
2. Cliquez sur **Add file > Upload files** et déposez `index.html`, `admin.html`, `style.css` et `config.js`.
3. Ouvrez **Settings > Pages**, choisissez **Deploy from a branch**, la branche `main` et le dossier `/ (root)`, puis **Save**.
4. Après une minute environ, le site est disponible à l'adresse `https://VOTRE-NOM.github.io/stagiaires/`.

Les liens à partager :

- agents : `https://VOTRE-NOM.github.io/stagiaires/`
- administrateur : `https://VOTRE-NOM.github.io/stagiaires/admin.html`

## 6. Tester

1. Connectez-vous sur la page de saisie avec un compte agent et enregistrez un stagiaire de test.
2. Sur `admin.html`, connectez-vous avec le compte administrateur : le stagiaire apparaît dans le tableau.
3. Vérifiez qu'un compte agent est bien refusé sur `admin.html`.

## Droits de chacun

| | Agent | Administrateur |
|---|---|---|
| Ajouter un stagiaire | oui | oui |
| Voir les saisies | les siennes, sur 24 h | toutes |
| Ajouter l'heure de sortie | ses saisies, sur 24 h | toutes |
| Modifier librement | non | oui |
| Supprimer | non | oui |
| Exporter vers Excel | non | oui |

## À savoir

- Le dépôt GitHub doit être public pour utiliser GitHub Pages gratuitement. Cela n'expose pas les données, qui restent dans Supabase et protégées par les règles du fichier SQL.
- Le plan gratuit de Supabase met un projet en pause après une semaine sans activité. Il se réactive en un clic depuis le tableau de bord.
- Si un agent oublie son mot de passe, l'administrateur peut le changer dans **Authentication > Users**.

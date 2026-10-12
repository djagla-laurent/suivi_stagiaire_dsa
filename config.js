// Remplacez ces deux valeurs par celles de votre projet Supabase
// (Supabase > Project Settings > API).
// La clé "anon public" peut être publique : la sécurité est assurée par les règles SQL.
// N'utilisez JAMAIS la clé "service_role" ici.
const SUPABASE_URL = "https://aoiltqmwplnhgzniyuma.supabase.co";
const SUPABASE_ANON_KEY = "sb_publishable_5LUfmiMGUVTmbxepYgzTKg_vw7ZJGRp";

const db = window.supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);

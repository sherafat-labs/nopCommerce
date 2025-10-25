-- Enable required extensions for nopCommerce
CREATE EXTENSION IF NOT EXISTS citext;
CREATE EXTENSION IF NOT EXISTS btree_gin;
CREATE EXTENSION IF NOT EXISTS btree_gist;

-- Create citext type if the extension is not available
DO $$ 
BEGIN
    -- Check if citext extension is available
    IF NOT EXISTS (SELECT 1 FROM pg_extension WHERE extname = 'citext') THEN
        -- If citext extension is not available, create a workaround
        CREATE DOMAIN citext AS text;
        
        -- Create case-insensitive functions for the domain
        CREATE OR REPLACE FUNCTION citext_eq (citext, citext)
        RETURNS boolean AS $$
            SELECT lower($1) = lower($2);
        $$ LANGUAGE SQL IMMUTABLE;

        CREATE OR REPLACE FUNCTION citext_ne (citext, citext)
        RETURNS boolean AS $$
            SELECT lower($1) <> lower($2);
        $$ LANGUAGE SQL IMMUTABLE;

        CREATE OR REPLACE FUNCTION citext_lt (citext, citext)
        RETURNS boolean AS $$
            SELECT lower($1) < lower($2);
        $$ LANGUAGE SQL IMMUTABLE;

        CREATE OR REPLACE FUNCTION citext_le (citext, citext)
        RETURNS boolean AS $$
            SELECT lower($1) <= lower($2);
        $$ LANGUAGE SQL IMMUTABLE;

        CREATE OR REPLACE FUNCTION citext_gt (citext, citext)
        RETURNS boolean AS $$
            SELECT lower($1) > lower($2);
        $$ LANGUAGE SQL IMMUTABLE;

        CREATE OR REPLACE FUNCTION citext_ge (citext, citext)
        RETURNS boolean AS $$
            SELECT lower($1) >= lower($2);
        $$ LANGUAGE SQL IMMUTABLE;

        -- Create operators
        CREATE OPERATOR = (
            LEFTARG = citext, RIGHTARG = citext, PROCEDURE = citext_eq,
            COMMUTATOR = =, NEGATOR = <>
        );

        CREATE OPERATOR <> (
            LEFTARG = citext, RIGHTARG = citext, PROCEDURE = citext_ne,
            COMMUTATOR = <>, NEGATOR = =
        );

        CREATE OPERATOR < (
            LEFTARG = citext, RIGHTARG = citext, PROCEDURE = citext_lt,
            COMMUTATOR = > , NEGATOR = >=
        );

        CREATE OPERATOR <= (
            LEFTARG = citext, RIGHTARG = citext, PROCEDURE = citext_le,
            COMMUTATOR = >= , NEGATOR = >
        );

        CREATE OPERATOR > (
            LEFTARG = citext, RIGHTARG = citext, PROCEDURE = citext_gt,
            COMMUTATOR = < , NEGATOR = <=
        );

        CREATE OPERATOR >= (
            LEFTARG = citext, RIGHTARG = citext, PROCEDURE = citext_ge,
            COMMUTATOR = <= , NEGATOR = <
        );
    END IF;
END $$;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Image_Display is
    Generic (
        largeur_ecran : integer:= 96;
        longeur_ecran : integer:= 64;
        Bpp: integer:= 16
    );
    Port (
        clk          : in  STD_LOGIC;
        reset        : in  STD_LOGIC;
        
        ram_addr     : out STD_LOGIC_VECTOR(12 downto 0);
        
        enable_pmod : in  STD_LOGIC;
        ram_data_in  : in  STD_LOGIC_VECTOR(Bpp-1 downto 0);
        
        pix_col      : out STD_LOGIC_VECTOR(6 downto 0);
        pix_row      : out STD_LOGIC_VECTOR(5 downto 0);
        pix_data_out : out STD_LOGIC_VECTOR(Bpp-1 downto 0);
        pix_write    : out STD_LOGIC
    );
end Image_Display;

architecture Behavioral of Image_Display is
    signal col_counter : integer range 0 to largeur_ecran-1 := 0;
    signal row_counter : integer range 0 to longeur_ecran-1 := 0;
    signal addr        : integer range 0 to (largeur_ecran * longeur_ecran - 1) := 0;
    
    signal actif : std_logic := '0';
begin

process(clk)  -- Ajout de reset en sensibilité
begin
    if rising_edge(clk) then
        if reset = '1' then  -- Reset asynchrone en premier
            col_counter <= 0;
            row_counter <= 0;
            addr <= 0;
            pix_write <= '0';
            actif <= '0';
        
        elsif (enable_pmod = '1') then
            actif <= '1';
        end if;
    
    
        if (actif = '1') then
            -- Calcul de l'adresse dans la RAM
            addr <= (row_counter * largeur_ecran + col_counter);
            
            -- Mise à jour des adresses et pixels
            ram_addr <= std_logic_vector(to_unsigned(addr, 13));
            pix_col <= std_logic_vector(to_unsigned(col_counter, 7));
            pix_row <= std_logic_vector(to_unsigned(row_counter, 6));
            
            -- Lire la RAM et envoyer les pixels à l'écran
            pix_data_out <= ram_data_in;
            pix_write <= '1';

            -- Incrément des compteurs
            if col_counter < largeur_ecran - 1 then
                col_counter <= col_counter + 1;
            else
                col_counter <= 0;
                if row_counter < longeur_ecran - 1 then
                    row_counter <= row_counter + 1;
                else
                    row_counter <= 0;
                    actif  <= '0';
                end if;
            end if;
        else 
            pix_write <= '0';
        end if;
        
    end if;
end process;
end Behavioral;







-- Version 2
--library IEEE;
--use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.NUMERIC_STD.ALL;

--entity Image_Display is
--    Generic (
--        largeur_ecran : integer:= 96;
--        longeur_ecran : integer:= 64;
--        Bpp: integer:= 16
--    );
--    Port (
--        clk          : in  STD_LOGIC;
--        reset        : in  STD_LOGIC;
        
--        ram_addr     : out STD_LOGIC_VECTOR(12 downto 0);
        
--        enable_pmod : in  STD_LOGIC;
--        ram_data_in  : in  STD_LOGIC_VECTOR(Bpp-1 downto 0);
        
--        pix_col      : out STD_LOGIC_VECTOR(6 downto 0);
--        pix_row      : out STD_LOGIC_VECTOR(5 downto 0);
--        pix_data_out : out STD_LOGIC_VECTOR(Bpp-1 downto 0);
--        pix_write    : out STD_LOGIC
--    );
--end Image_Display;

--architecture Behavioral of Image_Display is
--    signal col_counter : integer range 0 to largeur_ecran-1 := 0;
--    signal row_counter : integer range 0 to longeur_ecran-1 := 0;
--    signal addr        : integer range 0 to (largeur_ecran * longeur_ecran - 1) := 0;
    
--    signal actif : std_logic := '0';
--begin

--process(clk, reset)  -- Ajout de reset en sensibilité
--begin
--    if reset = '1' then  -- Reset asynchrone en premier
--        col_counter <= 0;
--        row_counter <= 0;
--        addr <= 0;
--        pix_write <= '0';
        
--    elsif rising_edge(clk) then
--        if (enable_pmod = '1') then
--            -- Calcul de l'adresse dans la RAM
--            addr <= (row_counter * largeur_ecran + col_counter);
            
--            -- Mise à jour des adresses et pixels
--            ram_addr <= std_logic_vector(to_unsigned(addr, 13));
--            pix_col <= std_logic_vector(to_unsigned(col_counter, 7));
--            pix_row <= std_logic_vector(to_unsigned(row_counter, 6));
            
--            -- Lire la RAM et envoyer les pixels à l'écran
--            pix_data_out <= ram_data_in;
--            pix_write <= '1';

--            -- Incrément des compteurs
--            if col_counter < largeur_ecran - 1 then
--                col_counter <= col_counter + 1;
--            else
--                col_counter <= 0;
--                if row_counter < longeur_ecran - 1 then
--                    row_counter <= row_counter + 1;
--                else
--                    row_counter <= 0;
--                end if;
--            end if;
--        else 
--            pix_write <= '0';
--        end if;
--    end if;
--end process;







--Version 1
--    process(clk)
--    begin
--        if rising_edge(clk) then
--        if (enable_pmod = '1') then
--            if reset = '1' then
--                col_counter <= 0;
--                row_counter <= 0;
--                addr <= 0;
--                pix_write <= '0';
--            else
--                -- Calcul de l'adresse dans la RAM
--                addr <= (row_counter * largeur_ecran + col_counter);
                
--                -- Mise à jour des adresses et pixels
--                ram_addr <= std_logic_vector(to_unsigned(addr, ram_addr'length));
--                pix_col <= std_logic_vector(to_unsigned(col_counter, pix_col'length));
--                pix_row <= std_logic_vector(to_unsigned(row_counter, pix_row'length));
                
--                -- Lire la RAM et envoyer les pixels à l'écran
--                pix_data_out <= ram_data_in;
--                pix_write <= '1';  -- Activer l'écriture du pixel

--                -- Incrément des compteurs de colonnes et lignes
--                if col_counter < largeur_ecran - 1 then
--                    col_counter <= col_counter + 1;
--                else
--                    col_counter <= 0;
--                    if row_counter < longeur_ecran - 1 then
--                        row_counter <= row_counter + 1;
--                    else
--                        row_counter <= 0;
--                    end if;
--                end if;
--            end if;
--        end if;
--        end if;
--    end process;

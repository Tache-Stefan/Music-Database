drop table Info_Card;
drop table User_Abonament;
drop table Playlist_Melodie;
drop table Playlist;
drop table Tip_Abonament;
drop table Melodie;
drop table Album;
drop table Artist;
drop table User_;

create table User_ (
email_user VARCHAR2(40) constraint email_user_pk primary key constraint email_like check (email_user like '%@%'),
nume_user VARCHAR2(30) unique,
parola_user VARCHAR2(30),
data_i DATE
);

create table Info_Card (
nr_card CHAR(16) constraint nr_card_pk primary key constraint nr_card_length check (length(trim(nr_card)) = 16),
data_exp DATE not null,
cvv CHAR(3) not null constraint cvv_length check (length(trim(cvv)) = 3),
nume_card VARCHAR2(30) not null,
prenume_card VARCHAR2(30) not null,
email_user VARCHAR2(40) not null,
constraint info_card_email_fk foreign key (email_user) references User_(email_user) on delete cascade
);

create table Tip_Abonament (
tip_abonament VARCHAR2(30) constraint tip_abonament_pk primary key,
pret_lunar NUMBER(4,2) constraint pret_lunar_check check (pret_lunar >= 0),
nr_dispozitive NUMBER(2) constraint nr_dispozitive_check check (nr_dispozitive > 0),
reclame CHAR(1) default 'Y' constraint reclame_check check (reclame in ('Y', 'N'))
);

create table User_Abonament (
email_user VARCHAR2(40),
tip_abonament VARCHAR2(30),
auto_reinnoire CHAR(1) default 'N' constraint auto_reinn_check check (auto_reinnoire in ('Y', 'N')),
constraint user_abon_pk primary key (email_user, tip_abonament),
constraint user_abon_email_fk foreign key (email_user) references User_(email_user) on delete cascade,
constraint user_abon_tip_fk foreign key (tip_abonament) references Tip_Abonament(tip_abonament) on delete cascade
);

create table Playlist (
id_playlist NUMBER(8) constraint id_playlist_pk primary key,
nume_playlist VARCHAR2(30),
tip CHAR(6) default 'public' constraint tip_check check (tip in ('public', 'privat')),
data_c DATE not null,
email_user VARCHAR2(40),
constraint playlist_email_fk foreign key (email_user) references User_(email_user) on delete cascade
);

create table Artist (
id_artist NUMBER(6) constraint artist_pk primary key,
nume_artist VARCHAR2(30) not null,
tara VARCHAR2(20),
data_nastere DATE
);

create table Album (
upc CHAR(14) constraint album_pk primary key,
titlu_album VARCHAR2(40),
casa_discuri VARCHAR2(40),
url_imagine VARCHAR2(60),
id_artist NUMBER(6) not null,
constraint album_artist_fk foreign key (id_artist) references Artist(id_artist) on delete cascade
);

alter table Album
add constraint upc_check check (
(length(trim(upc)) >= 12) or (upc like 'Single%')
);

create table Melodie (
id_melodie NUMBER(8) constraint melodie_pk primary key,
nume_melodie VARCHAR2(30) not null,
durata NUMBER(4) constraint durata_check check (durata > 0),
limba VARCHAR2(20),
data_lansare DATE not null,
upc CHAR(14) not null,
constraint melodie_upc_fk foreign key (upc) references Album(upc) on delete cascade
);

create table Playlist_Melodie (
id_playlist NUMBER(8),
id_melodie NUMBER(8),
stare_melodie VARCHAR2(7) default 'activa' constraint stare_melodie_check check (stare_melodie in ('activa', 'ascunsa')),
constraint playlist_melodie_pk primary key (id_playlist, id_melodie),
constraint id_playlist_fk foreign key (id_playlist) references Playlist(id_playlist) on delete cascade,
constraint id_melodie_fk foreign key (id_melodie) references Melodie(id_melodie) on delete cascade
);

create or replace view User_Playlist_View as
select p.id_playlist, p.nume_playlist, p.tip, p.data_c, p.email_user
from
    Playlist p
where
    p.email_user is null or
    exists (
        select 1 
        from User_ u 
        where u.email_user = p.email_user and u.data_i <= p.data_c
    )
with check option;

create or replace view Artist_Melodie_View as
select m.id_melodie, m.nume_melodie, m.durata, m.limba, m.data_lansare, m.upc
from Melodie m
where (
    not exists (
            select 1
            from Artist a left join Album al on a.id_artist = al.id_artist
            where al.upc = m.upc and a.data_nastere >= m.data_lansare)
)
with check option;

insert into Artist
values (1, 'Bruno_Mars', 'USA', to_date('08-10-1985','dd-mm-yyyy'));
insert into Artist
values (2, 'Ed_Sheeran', 'UK', to_date('17-02-1991','dd-mm-yyyy'));
insert into Artist
values (3, 'Rihanna', 'BB', to_date('20-02-1988','dd-mm-yyyy'));
insert into Artist
values (4, 'Drake', 'CA', to_date('24-10-1986','dd-mm-yyyy'));
insert into Artist
values (5, 'Smiley', 'RO', to_date('27-07-1983','dd-mm-yyyy'));
insert into Artist
values (6, 'NF', 'USA', to_date('30-03-1991','dd-mm-yyyy'));
insert into Artist
values (7, 'Delia', 'RO', to_date('07-02-1982','dd-mm-yyyy'));
insert into Artist
values (8, 'Randi', 'RO', to_date('23-05-1983','dd-mm-yyyy'));
insert into Artist
values (9, 'Post_Malone', 'USA', to_date('04-07-1995','dd-mm-yyyy'));
insert into Artist
values (10, 'Beyonce', 'USA', to_date('04-09-1981','dd-mm-yyyy'));
insert into Artist
values (11, 'Logic', 'USA', to_date('22-01-1990','dd-mm-yyyy'));
insert into Artist
values (12, 'The_Weeknd', 'CA', to_date('16-02-1990','dd-mm-yyyy'));
insert into Artist
values (13, 'Khalid', 'USA', to_date('11-02-1998', 'dd-mm-yyyy'));
insert into Artist
values (14, 'Taylor_Swift', 'USA', to_date('13-12-1989','dd-mm-yyyy'));
insert into Artist
values (15, 'Vescan', 'RO', to_date('26-05-1987','dd-mm-yyyy'));

insert into Album
values ('075679904126', '24K Magic', 'Atlantic Records', 'https://tinyurl.com/jbpc5afy', 1);
insert into Album
values ('825646284535', 'X', 'Atlantic Records', 'https://tinyurl.com/r5d9a4bt', 2);
insert into Album
values ('00602527829142', 'Loud', 'SRP Records', 'https://tinyurl.com/2w5djjde', 3);
insert into Album
values ('00602547943514', 'Views', 'Young Money Entertainment', 'https://tinyurl.com/2h754dva', 4);
insert into Album
values ('6420565432469', 'Acasa', 'Cat Music', 'https://tinyurl.com/2s3ffzzz', 5);
insert into Album
values ('00602547935885', 'Perception', 'NF Real Music', 'https://tinyurl.com/muy8rtc6', 6);
insert into Album
values ('00602567673507', 'Beerbongs and Bentleys', 'Republic Records', 'https://tinyurl.com/sd6vcd93', 9);
insert into Album
values ('00602435005300', 'No pressure', 'Def Jam Recordings', 'https://tinyurl.com/yn6ym7yw', 11);
insert into Album
values ('00602508924224', 'After Hours', 'XO', 'https://tinyurl.com/573za4ar', 12);
insert into Album
values ('886446309347', 'American Teen', 'RCA Records', 'https://tinyurl.com/4jszt92x', 13);
insert into Album
values ('Single8', null, null, null, 8);
insert into Album
values ('Single14', null, null, null, 14);
insert into Album
values ('Single15', null, null, null, 15);


insert into Artist_Melodie_View
values (1, 'Kalinka', 225, null, to_date('03-09-2018','dd-mm-yyyy'), 'Single8');
insert into Artist_Melodie_View
values (2, 'I Don''t Wanna Live Forever', 245, 'ENG', to_date('09-12-2016','dd-mm-yyyy'), 'Single14');
insert into Artist_Melodie_View
values (3, 'Piesa mea preferata', 248, 'RO', to_date('13-09-2013','dd-mm-yyyy'), 'Single15');
insert into Artist_Melodie_View
values (4, '24K Magic', 225, 'ENG', to_date('07-10-2016','dd-mm-yyyy'), '075679904126');
insert into Artist_Melodie_View
values (5, 'Chunky', 186, 'ENG', to_date('29-11-2017','dd-mm-yyyy'), '075679904126');
insert into Artist_Melodie_View
values (6, 'Perm', 210, 'ENG', to_date('18-11-2016','dd-mm-yyyy'), '075679904126');
insert into Artist_Melodie_View
values (7, 'That''s What I Like', 206, 'ENG', to_date('30-01-2017','dd-mm-yyyy'), '075679904126');
insert into Artist_Melodie_View
values (8, 'Versace on the Floor', 261, 'ENG', to_date('12-06-2017','dd-mm-yyyy'), '075679904126');
insert into Artist_Melodie_View
values (9, 'Straight Up and Down', 198, 'ENG', to_date('18-11-2016','dd-mm-yyyy'), '075679904126');
insert into Artist_Melodie_View
values (10, 'Calling All My Lovelies', 250, 'ENG', to_date('18-11-2016','dd-mm-yyyy'), '075679904126');
insert into Artist_Melodie_View
values (11, 'Finesse', 191, 'ENG', to_date('04-01-2018','dd-mm-yyyy'), '075679904126');
insert into Artist_Melodie_View
values (12, 'Too Good to Say Goodbye', 281, 'ENG', to_date('18-11-2016','dd-mm-yyyy'), '075679904126');
insert into Artist_Melodie_View
values (13, 'One', 253, 'ENG', to_date('16-05-2014','dd-mm-yyyy'), '825646284535');
insert into Artist_Melodie_View
values (14, 'I''m a Mess', 244, 'ENG', to_date('22-06-2014','dd-mm-yyyy'), '825646284535');
insert into Artist_Melodie_View
values (15, 'Sing', 235, 'ENG', to_date('07-04-2014','dd-mm-yyyy'), '825646284535');
insert into Artist_Melodie_View
values (16, 'Don''t', 219, 'ENG', to_date('24-08-2014','dd-mm-yyyy'), '825646284535');
insert into Artist_Melodie_View
values (17, 'Nina', 225, 'ENG', to_date('20-06-2014','dd-mm-yyyy'), '825646284535');
insert into Artist_Melodie_View
values (18, 'Photograph', 259, 'ENG', to_date('11-05-2015','dd-mm-yyyy'), '825646284535');
insert into Artist_Melodie_View
values (19, 'Bloodstream', 299, 'ENG', to_date('17-06-2014','dd-mm-yyyy'), '825646284535');
insert into Artist_Melodie_View
values (20, 'Tenerife Sea', 242, 'ENG', to_date('20-06-2014','dd-mm-yyyy'), '825646284535');
insert into Artist_Melodie_View
values (21, 'Runaway', 205, 'ENG', to_date('20-06-2014','dd-mm-yyyy'), '825646284535');
insert into Artist_Melodie_View
values (22, 'The Man', 249, 'ENG', to_date('19-06-2014','dd-mm-yyyy'), '825646284535');
insert into Artist_Melodie_View
values (23, 'Thinking Out Loud', 281, 'ENG', to_date('08-08-2014','dd-mm-yyyy'), '825646284535');
insert into Artist_Melodie_View
values (24, 'Afire Love', 314, 'ENG', to_date('16-06-2014','dd-mm-yyyy'), '825646284535');
insert into Artist_Melodie_View
values (25, 'Take It Back', 208, 'ENG', to_date('20-06-2014','dd-mm-yyyy'), '825646284535');
insert into Artist_Melodie_View
values (26, 'Shirtsleeves', 190, 'ENG', to_date('20-06-2014','dd-mm-yyyy'), '825646284535');
insert into Artist_Melodie_View
values (27, 'Even My Dad Does Sometimes', 228, 'ENG', to_date('20-06-2014','dd-mm-yyyy'), '825646284535');
insert into Artist_Melodie_View
values (28, 'I See Fire', 300, 'ENG', to_date('05-11-2013','dd-mm-yyyy'), '825646284535');
insert into Artist_Melodie_View
values (29, 'S and M', 243, 'ENG', to_date('23-01-2011','dd-mm-yyyy'), '00602527829142');
insert into Artist_Melodie_View
values (30, 'What''s My Name?', 263, 'ENG', to_date('25-10-2010','dd-mm-yyyy'), '00602527829142');
insert into Artist_Melodie_View
values (31, 'Cheers (Drink to That)', 262, 'ENG', to_date('02-08-2011','dd-mm-yyyy'), '00602527829142');
insert into Artist_Melodie_View
values (32, 'Fading', 207, 'ENG', to_date('12-11-2010','dd-mm-yyyy'), '00602527829142');
insert into Artist_Melodie_View
values (33, 'Only Girl (In the World)', 235, 'ENG', to_date('10-09-2010','dd-mm-yyyy'), '00602527829142');
insert into Artist_Melodie_View
values (34, 'California King Bed', 252, 'ENG', to_date('13-05-2011','dd-mm-yyyy'), '00602527829142');
insert into Artist_Melodie_View
values (35, 'Man Down', 268, 'ENG', to_date('03-05-2011','dd-mm-yyyy'), '00602527829142');
insert into Artist_Melodie_View
values (36, 'Raining Men', 224, 'ENG', to_date('07-12-2010','dd-mm-yyyy'), '00602527829142');
insert into Artist_Melodie_View
values (37, 'Complicated', 257, 'ENG', to_date('12-11-2010','dd-mm-yyyy'), '00602527829142');
insert into Artist_Melodie_View
values (38, 'Skin', 304, 'ENG', to_date('27-03-2011','dd-mm-yyyy'), '00602527829142');
insert into Artist_Melodie_View
values (39, 'Love the Way You Lie (Part II)', 296, 'ENG', to_date('12-11-2010','dd-mm-yyyy'), '00602527829142');
insert into Artist_Melodie_View
values (40, 'Keep The Family Close', 328, 'ENG', to_date('29-04-2016','dd-mm-yyyy'), '00602547943514');
insert into Artist_Melodie_View
values (41, '9', 255, 'ENG', to_date('29-04-2016','dd-mm-yyyy'), '00602547943514');
insert into Artist_Melodie_View
values (42, 'U With Me?', 297, 'ENG', to_date('29-04-2016','dd-mm-yyyy'), '00602547943514');
insert into Artist_Melodie_View
values (43, 'Feel No Ways', 240, 'ENG', to_date('29-04-2016','dd-mm-yyyy'), '00602547943514');
insert into Artist_Melodie_View
values (44, 'Hype', 209, 'ENG', to_date('29-04-2016','dd-mm-yyyy'), '00602547943514');
insert into Artist_Melodie_View
values (45, 'Weston Road Flows', 253, 'ENG', to_date('29-04-2016','dd-mm-yyyy'), '00602547943514');
insert into Artist_Melodie_View
values (46, 'Redemption', 333, 'ENG', to_date('29-04-2016','dd-mm-yyyy'), '00602547943514');
insert into Artist_Melodie_View
values (47, 'With You', 195, 'ENG', to_date('29-04-2016','dd-mm-yyyy'), '00602547943514');
insert into Artist_Melodie_View
values (48, 'Faithful', 290, 'ENG', to_date('29-04-2016','dd-mm-yyyy'), '00602547943514');
insert into Artist_Melodie_View
values (49, 'Still Here', 189, 'ENG', to_date('29-04-2016','dd-mm-yyyy'), '00602547943514');
insert into Artist_Melodie_View
values (50, 'Controlla', 245, 'ENG', to_date('29-04-2016','dd-mm-yyyy'), '00602547943514');
insert into Artist_Melodie_View
values (51, 'One Dance', 173, 'ENG', to_date('05-04-2016','dd-mm-yyyy'), '00602547943514');
insert into Artist_Melodie_View
values (52, 'Grammys', 280, 'ENG', to_date('29-04-2016','dd-mm-yyyy'), '00602547943514');
insert into Artist_Melodie_View
values (53, 'Childs Play', 241, 'ENG', to_date('29-04-2016','dd-mm-yyyy'), '00602547943514');
insert into Artist_Melodie_View
values (54, 'Pop Style', 212, 'ENG', to_date('05-04-2016','dd-mm-yyyy'), '00602547943514');
insert into Artist_Melodie_View
values (55, 'Too Good', 263, 'ENG', to_date('26-07-2016','dd-mm-yyyy'), '00602547943514');
insert into Artist_Melodie_View
values (56, 'Summers Over Interlude', 106, 'ENG', to_date('29-04-2016','dd-mm-yyyy'), '00602547943514');
insert into Artist_Melodie_View
values (57, 'Fire and Desire', 238, 'ENG', to_date('29-04-2016','dd-mm-yyyy'), '00602547943514');
insert into Artist_Melodie_View
values (58, 'Views', 311, 'ENG', to_date('29-04-2016','dd-mm-yyyy'), '00602547943514');
insert into Artist_Melodie_View
values (59, 'Hotline Bling', 267, 'ENG', to_date('31-07-2015','dd-mm-yyyy'), '00602547943514');
insert into Artist_Melodie_View
values (60, 'Can I get a ...', 207, 'ENG', to_date('21-11-2013','dd-mm-yyyy'), '6420565432469');
insert into Artist_Melodie_View
values (61, 'Acasa', 222, 'RO', to_date('1-11-2013','dd-mm-yyyy'), '6420565432469');
insert into Artist_Melodie_View
values (62, 'Hot in July', 224, 'ENG', to_date('21-11-2013','dd-mm-yyyy'), '6420565432469');
insert into Artist_Melodie_View
values (63, 'Inapoi in viitor', 212, 'RO', to_date('21-11-2013','dd-mm-yyyy'), '6420565432469');
insert into Artist_Melodie_View
values (64, 'Dead Man Walking', 201, 'ENG', to_date('31-05-2012','dd-mm-yyyy'), '6420565432469');
insert into Artist_Melodie_View
values (65, 'Pantofii altcuiva', 209, 'RO', to_date('21-11-2013','dd-mm-yyyy'), '6420565432469');
insert into Artist_Melodie_View
values (66, 'I Wish', 246, 'ENG', to_date('21-11-2013','dd-mm-yyyy'), '6420565432469');
insert into Artist_Melodie_View
values (67, 'Letter to You and Me', 227, 'ENG', to_date('21-11-2013','dd-mm-yyyy'), '6420565432469');
insert into Artist_Melodie_View
values (68, 'O ard trist', 227, 'RO', to_date('21-11-2013','dd-mm-yyyy'), '6420565432469');
insert into Artist_Melodie_View
values (69, 'Criminal', 202, 'ENG', to_date('05-06-2013','dd-mm-yyyy'), '6420565432469');
insert into Artist_Melodie_View
values (70, 'Pretindeai', 233, 'RO', to_date('21-11-2013','dd-mm-yyyy'), '6420565432469');
insert into Artist_Melodie_View
values (71, 'Hi, ce faci?', 208, 'RO', to_date('21-11-2013','dd-mm-yyyy'), '6420565432469');
insert into Artist_Melodie_View
values (72, 'Stupid Man', 204, 'ENG', to_date('14-11-2013','dd-mm-yyyy'), '6420565432469');
insert into Artist_Melodie_View
values (73, 'Conversatie', 223, 'RO', to_date('14-11-2013','dd-mm-yyyy'), '6420565432469');
insert into Artist_Melodie_View
values (74, 'Another Day', 216, 'ENG', to_date('14-11-2013','dd-mm-yyyy'), '6420565432469');
insert into Artist_Melodie_View
values (75, 'Nu deranjati!', 215, 'RO', to_date('14-11-2013','dd-mm-yyyy'), '6420565432469');
insert into Artist_Melodie_View
values (76, 'Wonderful Life', 220, 'ENG', to_date('21-11-2013','dd-mm-yyyy'), '6420565432469');
insert into Artist_Melodie_View
values (77, 'Nemuritori', 228, 'RO', to_date('24-04-2014','dd-mm-yyyy'), '6420565432469');
insert into Artist_Melodie_View
values (78, 'Intro III', 268, 'ENG', to_date('06-10-2017','dd-mm-yyyy'), '00602547935885');
insert into Artist_Melodie_View
values (79, 'Outcast', 325, 'ENG', to_date('06-10-2017','dd-mm-yyyy'), '00602547935885');
insert into Artist_Melodie_View
values (80, '10 Feet Down', 217, 'ENG', to_date('06-10-2017','dd-mm-yyyy'), '00602547935885');
insert into Artist_Melodie_View
values (81, 'Green Lights', 181, 'ENG', to_date('18-08-2017','dd-mm-yyyy'), '00602547935885');
insert into Artist_Melodie_View
values (82, 'Dreams', 221, 'ENG', to_date('06-10-2017','dd-mm-yyyy'), '00602547935885');
insert into Artist_Melodie_View
values (83, 'Let You Down', 212, 'ENG', to_date('14-09-2017','dd-mm-yyyy'), '00602547935885');
insert into Artist_Melodie_View
values (84, 'Destiny', 239, 'ENG', to_date('06-10-2017','dd-mm-yyyy'), '00602547935885');
insert into Artist_Melodie_View
values (85, 'My Life', 215, 'ENG', to_date('06-10-2017','dd-mm-yyyy'), '00602547935885');
insert into Artist_Melodie_View
values (86, 'You''re Special', 312, 'ENG', to_date('06-10-2017','dd-mm-yyyy'), '00602547935885');
insert into Artist_Melodie_View
values (87, 'If You Want Love', 199, 'ENG', to_date('06-10-2017','dd-mm-yyyy'), '00602547935885');
insert into Artist_Melodie_View
values (88, 'Remember This', 240, 'ENG', to_date('06-10-2017','dd-mm-yyyy'), '00602547935885');
insert into Artist_Melodie_View
values (89, 'Know', 238, 'ENG', to_date('06-10-2017','dd-mm-yyyy'), '00602547935885');
insert into Artist_Melodie_View
values (90, 'Lie', 209, 'ENG', to_date('06-10-2017','dd-mm-yyyy'), '00602547935885');
insert into Artist_Melodie_View
values (91, '3 A.M.', 218, 'ENG', to_date('06-10-2017','dd-mm-yyyy'), '00602547935885');
insert into Artist_Melodie_View
values (92, 'One Hundred', 192, 'ENG', to_date('06-10-2017','dd-mm-yyyy'), '00602547935885');
insert into Artist_Melodie_View
values (93, 'Outro', 212, 'ENG', to_date('02-08-2017','dd-mm-yyyy'), '00602547935885');
insert into Artist_Melodie_View
values (94, 'Paranoid', 221, 'ENG', to_date('27-04-2018','dd-mm-yyyy'), '00602567673507');
insert into Artist_Melodie_View
values (95, 'Spoil My Night', 194, 'ENG', to_date('27-04-2018','dd-mm-yyyy'), '00602567673507');
insert into Artist_Melodie_View
values (96, 'Rich and Sad', 206, 'ENG', to_date('27-04-2018','dd-mm-yyyy'), '00602567673507');
insert into Artist_Melodie_View
values (97, 'Zack And Codeine', 204, 'ENG', to_date('27-04-2018','dd-mm-yyyy'), '00602567673507');
insert into Artist_Melodie_View
values (98, 'Takin'' Shots', 216, 'ENG', to_date('27-04-2018','dd-mm-yyyy'), '00602567673507');
insert into Artist_Melodie_View
values (99, 'rockstar', 218, 'ENG', to_date('15-09-2017','dd-mm-yyyy'), '00602567673507');
insert into Artist_Melodie_View
values (100, 'Over Now', 246, 'ENG', to_date('27-04-2018','dd-mm-yyyy'), '00602567673507');
insert into Artist_Melodie_View
values (101, 'Psycho', 221, 'ENG', to_date('23-02-2018','dd-mm-yyyy'), '00602567673507');
insert into Artist_Melodie_View
values (102, 'Better Now', 231, 'ENG', to_date('25-05-2018','dd-mm-yyyy'), '00602567673507');
insert into Artist_Melodie_View
values (103, 'Ball For Me', 206, 'ENG', to_date('08-05-2018','dd-mm-yyyy'), '00602567673507');
insert into Artist_Melodie_View
values (104, 'Otherside', 228, 'ENG', to_date('27-04-2018','dd-mm-yyyy'), '00602567673507');
insert into Artist_Melodie_View
values (105, 'Stay', 204, 'ENG', to_date('27-04-2018','dd-mm-yyyy'), '00602567673507');
insert into Artist_Melodie_View
values (106, 'Blame It On Me', 261, 'ENG', to_date('27-04-2018','dd-mm-yyyy'), '00602567673507');
insert into Artist_Melodie_View
values (107, 'Same Bitches', 212, 'ENG', to_date('27-04-2018','dd-mm-yyyy'), '00602567673507');
insert into Artist_Melodie_View
values (108, 'Jonestown (Interlude)', 112, 'ENG', to_date('27-04-2018','dd-mm-yyyy'), '00602567673507');
insert into Artist_Melodie_View
values (109, '92 Explorer', 211, 'ENG', to_date('27-04-2018','dd-mm-yyyy'), '00602567673507');
insert into Artist_Melodie_View
values (110, 'Candy Paint', 227, 'ENG', to_date('20-10-2017','dd-mm-yyyy'), '00602567673507');
insert into Artist_Melodie_View
values (111, 'Sugar Wraith', 228, 'ENG', to_date('27-04-2018','dd-mm-yyyy'), '00602567673507');
insert into Artist_Melodie_View
values (112, 'No Pressure Intro', 174, 'ENG', to_date('24-07-2020','dd-mm-yyyy'), '00602435005300');
insert into Artist_Melodie_View
values (113, 'Hit My Line', 265, 'ENG', to_date('24-07-2020','dd-mm-yyyy'), '00602435005300');
insert into Artist_Melodie_View
values (114, 'GP4', 274, 'ENG', to_date('24-07-2020','dd-mm-yyyy'), '00602435005300');
insert into Artist_Melodie_View
values (115, 'Celebration', 230, 'ENG', to_date('24-07-2020','dd-mm-yyyy'), '00602435005300');
insert into Artist_Melodie_View
values (116, 'Open Mic\\Aquarius III', 303, 'ENG', to_date('24-07-2020','dd-mm-yyyy'), '00602435005300');
insert into Artist_Melodie_View
values (117, 'Soul Food II', 333, 'ENG', to_date('24-07-2020','dd-mm-yyyy'), '00602435005300');
insert into Artist_Melodie_View
values (118, 'Perfect', 100, 'ENG', to_date('24-07-2020','dd-mm-yyyy'), '00602435005300');
insert into Artist_Melodie_View
values (119, 'man i is', 269, 'ENG', to_date('24-07-2020','dd-mm-yyyy'), '00602435005300');
insert into Artist_Melodie_View
values (120, 'DadBod', 294, 'ENG', to_date('24-07-2020','dd-mm-yyyy'), '00602435005300');
insert into Artist_Melodie_View
values (121, '5 Hooks', 232, 'ENG', to_date('24-07-2020','dd-mm-yyyy'), '00602435005300');
insert into Artist_Melodie_View
values (122, 'Dark Place', 195, 'ENG', to_date('24-07-2020','dd-mm-yyyy'), '00602435005300');
insert into Artist_Melodie_View
values (123, 'A2Z', 188, 'ENG', to_date('24-07-2020','dd-mm-yyyy'), '00602435005300');
insert into Artist_Melodie_View
values (124, 'Heard Em Say', 216, 'ENG', to_date('24-07-2020','dd-mm-yyyy'), '00602435005300');
insert into Artist_Melodie_View
values (125, 'Amen', 146, 'ENG', to_date('24-07-2020','dd-mm-yyyy'), '00602435005300');
insert into Artist_Melodie_View
values (126, 'Obediently Yours', 369, 'ENG', to_date('24-07-2020','dd-mm-yyyy'), '00602435005300');
insert into Artist_Melodie_View
values (127, 'Alone Again', 250, 'ENG', to_date('20-03-2020','dd-mm-yyyy'), '00602508924224');
insert into Artist_Melodie_View
values (128, 'Too Late', 239, 'ENG', to_date('20-03-2020','dd-mm-yyyy'), '00602508924224');
insert into Artist_Melodie_View
values (129, 'Hardest To Love', 211, 'ENG', to_date('20-03-2020','dd-mm-yyyy'), '00602508924224');
insert into Artist_Melodie_View
values (130, 'Scared To Live', 191, 'ENG', to_date('20-03-2020','dd-mm-yyyy'), '00602508924224');
insert into Artist_Melodie_View
values (131, 'Snowchild', 247, 'ENG', to_date('20-03-2020','dd-mm-yyyy'), '00602508924224');
insert into Artist_Melodie_View
values (132, 'Escape From LA', 355, 'ENG', to_date('20-03-2020','dd-mm-yyyy'), '00602508924224');
insert into Artist_Melodie_View
values (133, 'Heartless', 198, 'ENG', to_date('27-11-2019','dd-mm-yyyy'), '00602508924224');
insert into Artist_Melodie_View
values (134, 'Faith', 283, 'ENG', to_date('20-03-2020','dd-mm-yyyy'), '00602508924224');
insert into Artist_Melodie_View
values (135, 'Blinding Lights', 200, 'ENG', to_date('29-11-2019','dd-mm-yyyy'), '00602508924224');
insert into Artist_Melodie_View
values (136, 'In Your Eyes', 237, 'ENG', to_date('24-03-2020','dd-mm-yyyy'), '00602508924224');
insert into Artist_Melodie_View
values (137, 'Save Your Tears', 215, 'ENG', to_date('09-08-2020','dd-mm-yyyy'), '00602508924224');
insert into Artist_Melodie_View
values (138, 'Repeat After Me (Interlude)', 195, 'ENG', to_date('20-03-2020','dd-mm-yyyy'), '00602508924224');
insert into Artist_Melodie_View
values (139, 'After Hours', 361, 'ENG', to_date('20-03-2020','dd-mm-yyyy'), '00602508924224');
insert into Artist_Melodie_View
values (140, 'Until I Bleed Out', 190, 'ENG', to_date('20-03-2020','dd-mm-yyyy'), '00602508924224');
insert into Artist_Melodie_View
values (141, 'American Teen', 250, 'ENG', to_date('03-03-2017','dd-mm-yyyy'), '886446309347');
insert into Artist_Melodie_View
values (142, 'Young Dumb and Broke', 202, 'ENG', to_date('13-06-2017','dd-mm-yyyy'), '886446309347');
insert into Artist_Melodie_View
values (143, 'Location', 219, 'ENG', to_date('30-04-2016','dd-mm-yyyy'), '886446309347');
insert into Artist_Melodie_View
values (144, 'Another Sad Love Song', 244, 'ENG', to_date('03-03-2017','dd-mm-yyyy'), '886446309347');
insert into Artist_Melodie_View
values (145, 'Saved', 206, 'ENG', to_date('30-10-2017','dd-mm-yyyy'), '886446309347');
insert into Artist_Melodie_View
values (146, 'Coaster', 199, 'ENG', to_date('16-12-2016','dd-mm-yyyy'), '886446309347');
insert into Artist_Melodie_View
values (147, '8TEEN', 228, 'ENG', to_date('03-03-2017','dd-mm-yyyy'), '886446309347');
insert into Artist_Melodie_View
values (148, 'Let''s Go', 204, 'ENG', to_date('12-09-2016','dd-mm-yyyy'), '886446309347');
insert into Artist_Melodie_View
values (149, 'Hopeless', 167, 'ENG', to_date('28-10-2016','dd-mm-yyyy'), '886446309347');
insert into Artist_Melodie_View
values (150, 'Cold Blooded', 207, 'ENG', to_date('03-03-2017','dd-mm-yyyy'), '886446309347');
insert into Artist_Melodie_View
values (151, 'Winter', 241, 'ENG', to_date('03-03-2017','dd-mm-yyyy'), '886446309347');
insert into Artist_Melodie_View
values (152, 'Therapy', 257, 'ENG', to_date('03-03-2017','dd-mm-yyyy'), '886446309347');
insert into Artist_Melodie_View
values (153, 'Keep Me', 276, 'ENG', to_date('03-03-2017','dd-mm-yyyy'), '886446309347');
insert into Artist_Melodie_View
values (154, 'Shot Down', 207, 'ENG', to_date('02-02-2017','dd-mm-yyyy'), '886446309347');
insert into Artist_Melodie_View
values (155, 'Angels', 170, 'ENG', to_date('03-03-2017','dd-mm-yyyy'), '886446309347');

insert into Tip_Abonament
values ('Free', 0.00, 1, 'Y');
insert into Tip_Abonament
values ('Premium', 5.99, 4, 'N');
insert into Tip_Abonament
values ('Pro', 9.99, 8, 'N');

insert into User_
values ('andreity@yahoo.com', 'Andrei23', 'd6#n26}3Hj', to_date('06-10-2019','dd-mm-yyyy'));
insert into User_
values ('mihai.popescu@yahoo.com', 'Mihay', '6tx;7P0hC?', to_date('19-08-2018','dd-mm-yyyy'));
insert into User_
values ('georgianlol@yahoo.com', 'jeorj', '9jrk/N27', to_date('02-01-2021','dd-mm-yyyy'));
insert into User_
values ('michaelino@yahoo.com', 'Mikey', 'vOi56)4}5', to_date('05-05-2020','dd-mm-yyyy'));
insert into User_
values ('kylian123@gmail.com', 'Kylian', 'manchester', to_date('15-06-2020','dd-mm-yyyy'));
insert into User_
values ('david190@gmail.com', 'David', 'fotbal098', to_date('28-10-2020','dd-mm-yyyy'));
insert into User_
values ('alexandruuu@ymail.com', 'alexandru', 'alexandru', to_date('21-02-2021','dd-mm-yyyy'));
insert into User_
values ('udryl@yahoo.com', 'Udryl', 'dLS84[?Lr6', to_date('17-03-2019','dd-mm-yyyy'));
insert into User_
values ('anaa.pop@gmail.com', 'anaa', 'rochie123', to_date('09-07-2020','dd-mm-yyyy'));
insert into User_
values ('mariayu@yahoo.com', 'Maker', '5J~r8V4', to_date('12-07-2018','dd-mm-yyyy'));
insert into User_
values ('horiann23@yahoo.com', 'horiann23', 'kA601#n', to_date('07-07-2020','dd-mm-yyyy'));
insert into User_
values ('lewis.hamilton@yahoo.com', 'Hamilton', 'ferrari', to_date('25-12-2022','dd-mm-yyyy'));
insert into User_
values ('someguy@yahoo.com', 'guY', '1!W70mJ', to_date('20-04-2020','dd-mm-yyyy'));
insert into User_
values ('laurentiuu@gmail.com', 'FIRST', 'v6<I62?s0', to_date('11-08-2020','dd-mm-yyyy'));

insert into Info_Card
values (5333002425214858, to_date('01-04-2027','dd-mm-yyyy'), 198, 'Ilie', 'Andrei', 'andreity@yahoo.com');
insert into Info_Card
values (5234698774576738, to_date('01-06-2029','dd-mm-yyyy'), 194, 'Popescu', 'Mihai', 'mihai.popescu@yahoo.com');
insert into Info_Card
values (5197262750527256, to_date('01-08-2026','dd-mm-yyyy'), 649, 'Popescu', 'Mihai', 'mihai.popescu@yahoo.com');
insert into Info_Card
values (5311440860703942, to_date('01-03-2028','dd-mm-yyyy'), 774, 'Tudor', 'Georgian', 'georgianlol@yahoo.com');
insert into Info_Card
values (5461962912582196, to_date('01-06-2025','dd-mm-yyyy'), 344, 'Stanley', 'Michael', 'michaelino@yahoo.com');
insert into Info_Card
values (5197798034108259, to_date('01-06-2025','dd-mm-yyyy'), 988, 'Stanley', 'Michael', 'michaelino@yahoo.com');
insert into Info_Card
values (5394429924994449, to_date('01-06-2029','dd-mm-yyyy'), 764, 'Harris', 'Kylian', 'kylian123@gmail.com');
insert into Info_Card
values (5261073513967661, to_date('01-02-2026','dd-mm-yyyy'), 922, 'Rusu', 'David', 'david190@gmail.com');
insert into Info_Card
values (5299736761505393, to_date('01-03-2025','dd-mm-yyyy'), 263, 'Stanciu', 'Luca', 'udryl@yahoo.com');
insert into Info_Card
values (5379008650454718, to_date('01-03-2027','dd-mm-yyyy'), 444, 'Pop', 'Ana', 'anaa.pop@gmail.com');
insert into Info_Card
values (5529619506615291, to_date('01-12-2027','dd-mm-yyyy'), 894, 'Gheorghe', 'Horia', 'horiann23@yahoo.com');
insert into Info_Card
values (5138369450896496, to_date('01-01-2027','dd-mm-yyyy'), 857, 'Hamilton', 'Lewis', 'lewis.hamilton@yahoo.com');
insert into Info_Card
values (5146951108952290, to_date('01-12-2027','dd-mm-yyyy'), 382, 'Hamilton', 'Lewis', 'lewis.hamilton@yahoo.com');
insert into Info_Card
values (5195863015541163, to_date('01-09-2026','dd-mm-yyyy'), 522, 'Hamilton', 'Lewis', 'lewis.hamilton@yahoo.com');
insert into Info_Card
values (5222147925319766, to_date('01-05-2026','dd-mm-yyyy'), 193, 'Moldovan', 'Laurentiu', 'laurentiuu@gmail.com');

insert into User_Abonament
values ('andreity@yahoo.com', 'Premium', 'N');
insert into User_Abonament
values ('mihai.popescu@yahoo.com', 'Pro', 'Y');
insert into User_Abonament
values ('georgianlol@yahoo.com', 'Premium', 'Y');
insert into User_Abonament
values ('michaelino@yahoo.com', 'Pro', 'Y');
insert into User_Abonament
values ('kylian123@gmail.com', 'Premium', 'N');
insert into User_Abonament
values ('david190@gmail.com', 'Free', 'N');
insert into User_Abonament
values ('alexandruuu@ymail.com', 'Free', 'N');
insert into User_Abonament
values ('udryl@yahoo.com', 'Premium', 'Y');
insert into User_Abonament
values ('anaa.pop@gmail.com', 'Free', 'N');
insert into User_Abonament
values ('mariayu@yahoo.com', 'Free', 'N');
insert into User_Abonament
values ('horiann23@yahoo.com', 'Premium', 'N');
insert into User_Abonament
values ('lewis.hamilton@yahoo.com', 'Pro', 'Y');
insert into User_Abonament
values ('someguy@yahoo.com', 'Free', 'N');
insert into User_Abonament
values ('laurentiuu@gmail.com', 'Premium', 'Y');

insert into User_Playlist_View
values (1, 'MyPlaylist', 'public', to_date('03-06-2023','dd-mm-yyyy'), 'andreity@yahoo.com');
insert into User_Playlist_View
values (2, 'Liked', 'public', to_date('18-12-2020','dd-mm-yyyy'), 'andreity@yahoo.com');
insert into User_Playlist_View
values (3, 'bad_nights', 'privat', to_date('01-09-2021','dd-mm-yyyy'), 'andreity@yahoo.com');
insert into User_Playlist_View
values (4, 'Myfavs', 'public', to_date('19-08-2018','dd-mm-yyyy'), 'mihai.popescu@yahoo.com');
insert into User_Playlist_View
values (5, 'just4me', 'privat', to_date('08-09-2021','dd-mm-yyyy'), 'georgianlol@yahoo.com');
insert into User_Playlist_View
values (6, 'preferate', 'public', to_date('02-03-2022','dd-mm-yyyy'), 'georgianlol@yahoo.com');
insert into User_Playlist_View
values (7, 'idk', 'privat', to_date('19-05-2023','dd-mm-yyyy'), 'michaelino@yahoo.com');
insert into User_Playlist_View
values (8, 'copiati', 'public', to_date('29-09-2020','dd-mm-yyyy'), 'kylian123@gmail.com');
insert into User_Playlist_View
values (9, 'privateeee', 'privat', to_date('03-01-2021','dd-mm-yyyy'), 'kylian123@gmail.com');
insert into User_Playlist_View
values (10, 'petrecere', 'public', to_date('11-11-2020','dd-mm-yyyy'), 'david190@gmail.com');
insert into User_Playlist_View
values (11, 'ascult', 'public', to_date('12-02-2020','dd-mm-yyyy'), 'udryl@yahoo.com');
insert into User_Playlist_View
values (12, 'haters', 'privat', to_date('23-11-2022','dd-mm-yyyy'), 'anaa.pop@gmail.com');
insert into User_Playlist_View
values (13, 'everyb@dy', 'public', to_date('17-07-2023','dd-mm-yyyy'), 'horiann23@yahoo.com');
insert into User_Playlist_View
values (14, 'NAH', 'privat', to_date('06-11-2022','dd-mm-yyyy'), 'horiann23@yahoo.com');
insert into User_Playlist_View
values (15, 'old_days', 'privat', to_date('01-01-2023','dd-mm-yyyy'), 'lewis.hamilton@yahoo.com');
insert into User_Playlist_View
values (16, 'lul', 'public', to_date('18-07-2023','dd-mm-yyyy'), 'someguy@yahoo.com');
insert into User_Playlist_View
values (17, 'nu', 'privat', to_date('22-09-2020','dd-mm-yyyy'), 'laurentiuu@gmail.com');
insert into User_Playlist_View
values (18, 'Publicorino', 'public', to_date('01-10-2021','dd-mm-yyyy'), null);
insert into User_Playlist_View
values (19, 'Random', 'public', to_date('15-05-2021','dd-mm-yyyy'), null);

insert into Playlist_Melodie
values (1, 24, 'activa');
insert into Playlist_Melodie
values (1, 52, 'activa');
insert into Playlist_Melodie
values (1, 1, 'activa');
insert into Playlist_Melodie
values (1, 8, 'activa');
insert into Playlist_Melodie
values (1, 20, 'ascunsa');
insert into Playlist_Melodie
values (1, 19, 'activa');
insert into Playlist_Melodie
values (2, 141, 'activa');
insert into Playlist_Melodie
values (2, 2, 'activa');
insert into Playlist_Melodie
values (2, 42, 'activa');
insert into Playlist_Melodie
values (2, 43, 'activa');
insert into Playlist_Melodie
values (3, 59, 'activa');
insert into Playlist_Melodie
values (3, 81, 'activa');
insert into Playlist_Melodie
values (3, 83, 'activa');
insert into Playlist_Melodie
values (4, 100, 'activa');
insert into Playlist_Melodie
values (4, 13, 'activa');
insert into Playlist_Melodie
values (4, 82, 'activa');
insert into Playlist_Melodie
values (4, 92, 'activa');
insert into Playlist_Melodie
values (4, 131, 'activa');
insert into Playlist_Melodie
values (4, 105, 'activa');
insert into Playlist_Melodie
values (4, 150, 'activa');
insert into Playlist_Melodie
values (4, 24, 'activa');
insert into Playlist_Melodie
values (5, 17, 'ascunsa');
insert into Playlist_Melodie
values (5, 41, 'activa');
insert into Playlist_Melodie
values (5, 73, 'activa');
insert into Playlist_Melodie
values (5, 81, 'activa');
insert into Playlist_Melodie
values (5, 30, 'activa');
insert into Playlist_Melodie
values (6, 58, 'activa');
insert into Playlist_Melodie
values (6, 8, 'activa');
insert into Playlist_Melodie
values (6, 142, 'activa');
insert into Playlist_Melodie
values (6, 99, 'ascunsa');
insert into Playlist_Melodie
values (6, 101, 'activa');
insert into Playlist_Melodie
values (6, 86, 'activa');
insert into Playlist_Melodie
values (7, 115, 'activa');
insert into Playlist_Melodie
values (7, 7, 'activa');
insert into Playlist_Melodie
values (7, 3, 'activa');
insert into Playlist_Melodie
values (7, 62, 'ascunsa');
insert into Playlist_Melodie
values (7, 61, 'activa');
insert into Playlist_Melodie
values (7, 96, 'activa');
insert into Playlist_Melodie
values (7, 121, 'activa');
insert into Playlist_Melodie
values (7, 71, 'activa');
insert into Playlist_Melodie
values (8, 145, 'activa');
insert into Playlist_Melodie
values (8, 146, 'activa');
insert into Playlist_Melodie
values (8, 147, 'activa');
insert into Playlist_Melodie
values (9, 155, 'activa');
insert into Playlist_Melodie
values (10, 120, 'ascunsa');
insert into Playlist_Melodie
values (10, 10, 'activa');
insert into Playlist_Melodie
values (10, 20, 'activa');
insert into Playlist_Melodie
values (10, 30, 'activa');
insert into Playlist_Melodie
values (10, 40, 'activa');
insert into Playlist_Melodie
values (10, 50, 'activa');
insert into Playlist_Melodie
values (11, 60, 'activa');
insert into Playlist_Melodie
values (11, 78, 'activa');
insert into Playlist_Melodie
values (11, 13, 'activa');
insert into Playlist_Melodie
values (11, 44, 'ascunsa');
insert into Playlist_Melodie
values (11, 58, 'activa');
insert into Playlist_Melodie
values (11, 71, 'activa');
insert into Playlist_Melodie
values (12, 148, 'activa');
insert into Playlist_Melodie
values (12, 9, 'activa');
insert into Playlist_Melodie
values (12, 103, 'activa');
insert into Playlist_Melodie
values (12, 55, 'activa');
insert into Playlist_Melodie
values (12, 23, 'activa');
insert into Playlist_Melodie
values (13, 81, 'activa');
insert into Playlist_Melodie
values (13, 82, 'activa');
insert into Playlist_Melodie
values (13, 12, 'activa');
insert into Playlist_Melodie
values (14, 25, 'activa');
insert into Playlist_Melodie
values (14, 26, 'activa');
insert into Playlist_Melodie
values (14, 82, 'ascunsa');
insert into Playlist_Melodie
values (14, 89, 'activa');
insert into Playlist_Melodie
values (14, 131, 'activa');
insert into Playlist_Melodie
values (14, 144, 'activa');
insert into Playlist_Melodie
values (15, 75, 'activa');
insert into Playlist_Melodie
values (15, 54, 'activa');
insert into Playlist_Melodie
values (15, 51, 'activa');
insert into Playlist_Melodie
values (15, 29, 'activa');
insert into Playlist_Melodie
values (15, 27, 'activa');
insert into Playlist_Melodie
values (15, 114, 'activa');
insert into Playlist_Melodie
values (16, 1, 'activa');
insert into Playlist_Melodie
values (16, 4, 'activa');
insert into Playlist_Melodie
values (16, 6, 'activa');
insert into Playlist_Melodie
values (17, 25, 'ascunsa');
insert into Playlist_Melodie
values (18, 75, 'activa');
insert into Playlist_Melodie
values (18, 96, 'activa');
insert into Playlist_Melodie
values (18, 98, 'activa');
insert into Playlist_Melodie
values (18, 1, 'activa');
insert into Playlist_Melodie
values (18, 7, 'activa');
insert into Playlist_Melodie
values (18, 16, 'activa');
insert into Playlist_Melodie
values (18, 43, 'activa');
insert into Playlist_Melodie
values (18, 116, 'activa');
insert into Playlist_Melodie
values (18, 146, 'activa');
insert into Playlist_Melodie
values (19, 58, 'activa');
insert into Playlist_Melodie
values (19, 63, 'ascunsa');
insert into Playlist_Melodie
values (19, 76, 'activa');
insert into Playlist_Melodie
values (19, 81, 'activa');

commit;
package tools;
import ui.win.LevelUp;
import h2d.Tile;

class LevelUpManager {
    public function new() {
    }

    //array skils {name, desc, icon}
    private static var skills = [
        [["Plazma Topu", "Plazma topu yeteneğinizi aktif eder.", D.tiles.plazmaicon], ["Plazma Topu 2", "1 adet daha plazma topu ekler.", D.tiles.plazmaicon]],
        [["Karanlık Şişmek", "Rastgele bir düşmanın üzerine şişmek düşer.", D.tiles.darklightningicon], ["Karanlık Şişmek 2", "Şimşeğin hasarını 5 arttırır.", D.tiles.darklightningicon], ["Karanlık Şişmek 3", "Daha sık şimşek atarsınız.", D.tiles.darklightningicon]],
        [["Teme Saldırı Gücü", "Temel saldırı gücünüzü 1 arttırır.", D.tiles.sword]],
        [["Maksimium Sağlık +%10", "Maksimum sağlığınızı yüzde 10 arttırır.", D.tiles.heart]],
    ] ;

    private static function getRandSkill() {
        //rastgele benzersiz 3 skill seç eğer activeSkillsde o skill var ve max levelde ise tekrar seç
        var randomSkills = [];
        var i = 0;
        while (i < 3) {
            var rand = Math.round(Math.random() * (skills.length - 1));
            if (randomSkills.indexOf(rand) == -1) {
                if (Game.ME.player.activeSkills[rand] == null || Game.ME.player.activeSkills[rand] < skills[rand].length - 1) {
                    randomSkills.push(rand);
                }
                i++;
            }
        }
        return randomSkills;

    }


    private static function activeSkill(type:Float, level:Float) {
        switch (type) {
            case 0:
                switch (level) {
                    case 0:
                        Game.ME.player.addNewParticle();
                        Game.ME.hud.addNewSkillSlot(D.tiles.plazmaslot);
                    case 1:
                        Game.ME.player.addNewParticle();
                }
            case 1:
                switch (level) {
                    case 0:
                        Game.ME.player.darkLightningSkillActive = true;
                        Game.ME.hud.addNewSkillSlot(D.tiles.darklightningslot);
                    case 1:
                        Game.ME.player.darkLightningSkillDamage += 5;
                    case 2:
                        Game.ME.player.darkLightningSkillCooldown -= 100;
                }
            case 2:
                Game.ME.player.mainDamage++;
            case 3:
                Game.ME.player.initLife(Math.round(Game.ME.player.getLifeMax() * 1.1));
                Game.ME.player.renderLife(Game.ME.player.getLifeValue(), 100);
        }
    }

    public static function openLevelUp() {
        var levelUpMenu = new LevelUp(true);
        levelUpMenu.addTitle("Seviye Atladın!");

        //random 3 skill
        var randomSkills = getRandSkill();
        for (skill in randomSkills) {

            var skill_level = Game.ME.player.activeSkills[skill] == null ? 0 : Game.ME.player.activeSkills[skill];

            levelUpMenu.addButton(skills[skill][skill_level][0], () -> {
                activeSkill(skill, skill_level);
                Game.ME.player.activeSkills[skill] = skill_level + 1;
            }, skills[skill][skill_level][1], skills[skill][skill_level][2]);
        }

    }
}

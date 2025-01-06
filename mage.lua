ConRO.Mage = {};
ConRO.Mage.CheckTalents = function()
end
ConRO.Mage.CheckPvPTalents = function()
end
local ConRO_Mage, ids = ...;

function ConRO:EnableRotationModule(mode)
	mode = mode or 0;
	self.ModuleOnEnable = ConRO.Mage.CheckTalents;
	self.ModuleOnEnable = ConRO.Mage.CheckPvPTalents;
	if mode == 0 then
		self.Description = "Mage [No Specialization Under 10]";
		self.NextSpell = ConRO.Mage.Under10;
		self.ToggleHealer();
	end;
	if mode == 1 then
		self.Description = "Mage [Arcane - Caster]";
		if ConRO.db.profile._Spec_1_Enabled then
			self.NextSpell = ConRO.Mage.Arcane;
			self.ToggleDamage();
			ConROWindow:SetAlpha(ConRO.db.profile.transparencyWindow);
			ConRODefenseWindow:SetAlpha(ConRO.db.profile.transparencyWindow);
		else
			self.NextSpell = ConRO.Mage.Disabled;
			self.ToggleHealer();
			ConROWindow:SetAlpha(0);
			ConRODefenseWindow:SetAlpha(0);
		end
	end;
	if mode == 2 then
		self.Description = "Mage [Fire - Caster]";
		if ConRO.db.profile._Spec_2_Enabled then
			self.NextSpell = ConRO.Mage.Fire;
			self.ToggleDamage();
			ConROWindow:SetAlpha(ConRO.db.profile.transparencyWindow);
			ConRODefenseWindow:SetAlpha(ConRO.db.profile.transparencyWindow);
		else
			self.NextSpell = ConRO.Mage.Disabled;
			self.ToggleHealer();
			ConROWindow:SetAlpha(0);
			ConRODefenseWindow:SetAlpha(0);
		end
	end;
	if mode == 3 then
		self.Description = "Mage [Frost - Caster]";
		if ConRO.db.profile._Spec_3_Enabled then
			self.NextSpell = ConRO.Mage.Frost;
			self.ToggleDamage();
			ConROWindow:SetAlpha(ConRO.db.profile.transparencyWindow);
			ConRODefenseWindow:SetAlpha(ConRO.db.profile.transparencyWindow);
		else
			self.NextSpell = ConRO.Mage.Disabled;
			self.ToggleHealer();
			ConROWindow:SetAlpha(0);
			ConRODefenseWindow:SetAlpha(0);
		end
	end;
	self:RegisterEvent('UNIT_SPELLCAST_SUCCEEDED');
	self.lastSpellId = 0;
end

function ConRO:EnableDefenseModule(mode)
	mode = mode or 0;
	if mode == 0 then
		self.NextDef = ConRO.Mage.Under10Def;
	end;
	if mode == 1 then
		if ConRO.db.profile._Spec_1_Enabled then
			self.NextDef = ConRO.Mage.ArcaneDef;
		else
			self.NextDef = ConRO.Mage.Disabled;
		end
	end;
	if mode == 2 then
		if ConRO.db.profile._Spec_2_Enabled then
			self.NextDef = ConRO.Mage.FireDef;
		else
			self.NextDef = ConRO.Mage.Disabled;
		end
	end;
	if mode == 3 then
		if ConRO.db.profile._Spec_3_Enabled then
			self.NextDef = ConRO.Mage.FrostDef;
		else
			self.NextDef = ConRO.Mage.Disabled;
		end
	end;
end

function ConRO:UNIT_SPELLCAST_SUCCEEDED(event, unitID, lineID, spellID)
	if unitID == 'player' then
		self.lastSpellId = spellID;
	end
end

function ConRO.Mage.Disabled(_, timeShift, currentSpell, gcd, tChosen, pvpChosen)
	return nil;
end

--Info
local _Player_Level = UnitLevel("player");
local _Player_Percent_Health = ConRO:PercentHealth('player');
local _is_PvP = ConRO:IsPvP();
local _in_combat = UnitAffectingCombat('player');
local _party_size = GetNumGroupMembers();
local _is_PC = UnitPlayerControlled("target");
local _is_Enemy = ConRO:TarHostile();
local _Target_Health = UnitHealth('target');
local _Target_Percent_Health = ConRO:PercentHealth('target');

--Resources
local _Mana, _Mana_Max, _Mana_Percent = ConRO:PlayerPower('Mana');
local _ArcaneCharges = ConRO:PlayerPower('ArcaneCharges');

--Conditions
local _Queue = 0;
local _is_moving = ConRO:PlayerSpeed();
local _enemies_in_melee, _target_in_melee = ConRO:Targets("Melee");
local _enemies_in_10yrds, _target_in_10yrds = ConRO:Targets("10");
local _enemies_in_25yrds, _target_in_25yrds = ConRO:Targets("25");
local _enemies_in_40yrds, _target_in_40yrds = ConRO:Targets("40");
local _can_Execute = _Target_Percent_Health < 20;

--Racials
local _AncestralCall, _AncestralCall_RDY = _, _;
local _ArcanePulse, _ArcanePulse_RDY = _, _;
local _Berserking, _Berserking_RDY = _, _;
local _ArcaneTorrent, _ArcaneTorrent_RDY = _, _;

local HeroSpec, Racial = ids.HeroSpec, ids.Racial;

function ConRO:Stats()
	_Player_Level = UnitLevel("player");
	_Player_Percent_Health = ConRO:PercentHealth('player');
	_is_PvP = ConRO:IsPvP();
	_in_combat = UnitAffectingCombat('player');
	_party_size = GetNumGroupMembers();
	_is_PC = UnitPlayerControlled("target");
	_is_Enemy = ConRO:TarHostile();
	_Target_Health = UnitHealth('target');
	_Target_Percent_Health = ConRO:PercentHealth('target');

	_Mana, _Mana_Max, _Mana_Percent = ConRO:PlayerPower('Mana');
	_ArcaneCharges = ConRO:PlayerPower('ArcaneCharges');

	_Queue = 0;
	_is_moving = ConRO:PlayerSpeed();
	_enemies_in_melee, _target_in_melee = ConRO:Targets("Melee");
	_enemies_in_10yrds, _target_in_10yrds = ConRO:Targets("10");
	_enemies_in_25yrds, _target_in_25yrds = ConRO:Targets("25");
	_enemies_in_40yrds, _target_in_40yrds = ConRO:Targets("40");
	_can_Execute = _Target_Percent_Health < 20;

	_AncestralCall, _AncestralCall_RDY = ConRO:AbilityReady(Racial.AncestralCall, timeShift);
	_ArcanePulse, _ArcanePulse_RDY = ConRO:AbilityReady(Racial.ArcanePulse, timeShift);
	_Berserking, _Berserking_RDY = ConRO:AbilityReady(Racial.Berserking, timeShift);
	_ArcaneTorrent, _ArcaneTorrent_RDY = ConRO:AbilityReady(Racial.ArcaneTorrent, timeShift);
end

function ConRO.Mage.Under10(_, timeShift, currentSpell, gcd, tChosen, pvpChosen)
	wipe(ConRO.SuggestedSpells);
	ConRO:Stats();
	local Ability, Form, Buff, Debuff, PetAbility, PvPTalent = ids.Mage_Ability, ids.Mage_Form, ids.Mage_Buff, ids.Mage_Debuff, ids.Mage_PetAbility, ids.Mage_PvPTalent;

--Abilities

--Conditions

--Warnings

--Rotations	


	return nil;
end

function ConRO.Mage.Under10Def(_, timeShift, currentSpell, gcd, tChosen, pvpChosen)
	wipe(ConRO.SuggestedDefSpells);
	ConRO:Stats();
	local Ability, Form, Buff, Debuff, PetAbility, PvPTalent = ids.Mage_Ability, ids.Mage_Form, ids.Mage_Buff, ids.Mage_Debuff, ids.Mage_PetAbility, ids.Mage_PvPTalent;

--Abilities

--Conditions

--Warnings

--Rotations	

	return nil;
end

function ConRO.Mage.Arcane(_, timeShift, currentSpell, gcd, tChosen, pvpChosen)
	wipe(ConRO.SuggestedSpells);
	ConRO:Stats();
	local Ability, Form, Buff, Debuff, PetAbility, PvPTalent = ids.Arc_Ability, ids.Arc_Form, ids.Arc_Buff, ids.Arc_Debuff, ids.Arc_PetAbility, ids.Arc_PvPTalent;

--Abilties	
	local _ArcaneBarrage, _ArcaneBarrage_RDY = ConRO:AbilityReady(Ability.ArcaneBarrage, timeShift);
		local _ArcaneSoul_BUFF, _, _ArcaneSoul_DUR = ConRO:Aura(Buff.ArcaneSoul, timeShift);
		local _GloriousIncandescence_BUFF = ConRO:Aura(Buff.GloriousIncandescence, timeShift);
	local _ArcaneBlast, _ArcaneBlast_RDY = ConRO:AbilityReady(Ability.ArcaneBlast, timeShift);
		local _Aethervision_BUFF, _Aethervision_COUNT = ConRO:Aura(Buff.Aethervision, timeShift);
		local _ArcaneTempo_BUFF, _ArcaneTempo_COUNT, _ArcaneTempo_DUR = ConRO:Aura(Buff.ArcaneTempo, timeShift);
		local _Leydrinker_BUFF = ConRO:Aura(Buff.Leydrinker, timeShift);
	local _ArcaneExplosion, _ArcaneExplosion_RDY = ConRO:AbilityReady(Ability.ArcaneExplosion, timeShift);
	local _ArcaneIntellect, _ArcaneIntellect_RDY = ConRO:AbilityReady(Ability.ArcaneIntellect, timeShift);
		local _ArcaneFamiliar_BUFF = ConRO:Aura(Buff.ArcaneFamiliar, timeShift);
	local _ArcaneMissiles, _ArcaneMissiles_RDY = ConRO:AbilityReady(Ability.ArcaneMissiles, timeShift);
		local _, _ArcaneHarmony_COUNT = ConRO:Form(Form.ArcaneHarmony);
		local _Clearcasting_BUFF, _Clearcasting_COUNT = ConRO:Aura(Buff.Clearcasting, timeShift);
		local _NetherPrecision_BUFF = ConRO:Aura(Buff.NetherPrecision, timeShift);
	local _ArcaneOrb, _ArcaneOrb_RDY = ConRO:AbilityReady(Ability.ArcaneOrb, timeShift);
		local _ArcaneOrb_CHARGES = ConRO:SpellCharges(_ArcaneOrb);
	local _ArcaneSurge, _ArcaneSurge_RDY, _ArcaneSurge_CD = ConRO:AbilityReady(Ability.ArcaneSurge, timeShift);
		local _ArcaneSurge_BUFF = ConRO:Aura(Buff.ArcaneSurge, timeShift);
	local _Blink, _Blink_RDY = ConRO:AbilityReady(Ability.Blink, timeShift);
	local _Counterspell, _Counterspell_RDY = ConRO:AbilityReady(Ability.Counterspell, timeShift);
	local _Evocation, _Evocation_RDY, _Evocation_CD = ConRO:AbilityReady(Ability.Evocation, timeShift);
		local _SiphonStorm_BUFF = ConRO:Aura(Buff.SiphonStorm, timeShift);
	local _MirrorImage, _MirrorImage_RDY = ConRO:AbilityReady(Ability.MirrorImage, timeShift);
	local _PresenceofMind, _PresenceofMind_RDY = ConRO:AbilityReady(Ability.PresenceofMind, timeShift);
		local _PresenceofMind_BUFF = ConRO:Form(Form.PresenceofMind);
	local _ShiftingPower, _ShiftingPower_RDY = ConRO:AbilityReady(Ability.ShiftingPower, timeShift);
	local _Spellsteal, _Spellsteal_RDY = ConRO:AbilityReady(Ability.Spellsteal, timeShift);
	local _Supernova, _Supernova_RDY = ConRO:AbilityReady(Ability.Supernova, timeShift);
		local _, _UnerringProficiency_COUNT = ConRO:Aura(Buff.UnerringProficiency, timeShift);
	local _TimeWarp, _TimeWarp_RDY = ConRO:AbilityReady(Ability.TimeWarp, timeShift);
		local _, _TemporalDisplacement = ConRO:Heroism();
	local _TouchoftheMagi, _TouchoftheMagi_RDY, _TouchoftheMagi_CD = ConRO:AbilityReady(Ability.TouchoftheMagi, timeShift);
		local _TouchoftheMagi_DEBUFF, _, _TouchoftheMagi_DUR = ConRO:TargetAura(Debuff.TouchoftheMagi, timeShift);

		local _Intuition_BUFF = ConRO:Aura(Buff.Intuition, timeShift);

--Conditions
	local _enemies_in_15yrds, _target_in_15yrds = ConRO:Targets("15");

	if tChosen[Ability.Shimmer.talentID] then
		_Blink, _Blink_RDY = ConRO:AbilityReady(Ability.Shimmer, timeShift);
	end

	if currentSpell == _ArcaneBlast then
		_ArcaneCharges = _ArcaneCharges + 1;
	end

	if _is_PvP then
		if pvpChosen[PvPTalent.ArcaneEmpowerment] then
			_Clearcasting_BUFF, _Clearcasting_COUNT = ConRO:Aura(Buff.ClearcastingAE, timeShift);
		end
	end

--Indicators	
	ConRO:AbilityInterrupt(_Counterspell, _Counterspell_RDY and ConRO:Interrupt());
	ConRO:AbilityPurge(_Spellsteal, _Spellsteal_RDY and ConRO:Purgable());
	ConRO:AbilityPurge(_ArcaneTorrent, _ArcaneTorrent_RDY and _target_in_10yrds and ConRO:Purgable());
	ConRO:AbilityMovement(_Blink, _Blink_RDY and _target_in_melee);

	ConRO:AbilityRaidBuffs(_ArcaneIntellect, _ArcaneIntellect_RDY and not ConRO:RaidBuff(Buff.ArcaneIntellect));

	ConRO:AbilityBurst(_ArcaneSurge, _ArcaneSurge_RDY and (currentSpell ~= _Evocation or ConRO.lastSpellId == _Evocation) and ConRO:BurstMode(_ArcaneSurge));
	ConRO:AbilityBurst(_Evocation, _Evocation_RDY and _ArcaneSurge_RDY and _TouchoftheMagi_RDY and ConRO:BurstMode(_Evocation));
	ConRO:AbilityBurst(_PresenceofMind, _PresenceofMind_RDY and not _PresenceofMind_BUFF and _ArcanePower_BUFF and _ArcanePower_DUR <= 3 and ConRO:BurstMode(_PresenceofMind));
	ConRO:AbilityBurst(_TouchoftheMagi, _TouchoftheMagi_RDY and _ArcaneCharges <= 0 and currentSpell ~= _TouchoftheMagi and ConRO:BurstMode(_TouchoftheMagi));
	ConRO:AbilityBurst(_ShiftingPower, _ShiftingPower_RDY and not _ArcaneSurge_RDY and not _Evocation_RDY and not _TouchoftheMagi_RDY and not _ArcaneSurge_BUFF and ConRO:BurstMode(_ShiftingPower));

--Warnings	

--Rotations
	repeat
		while(true) do
			if select(8, UnitChannelInfo("player")) == _Evocation then
				tinsert(ConRO.SuggestedSpells, _Evocation);
				_Evocation = 0;
				_Queue = _Queue + 1;
				break;
			end

			if select(8, UnitChannelInfo("player")) == _ShiftingPower then
				tinsert(ConRO.SuggestedSpells, _ShiftingPower);
				_ShiftingPower = 0;
				_Queue = _Queue + 1;
				break;
			end

			if not _in_combat then
				if _MirrorImage_RDY and not (_is_PvP or ConRO_PvPButton:IsVisible()) and ConRO:FullMode(_MirrorImage) then
					tinsert(ConRO.SuggestedSpells, _MirrorImage);
					_MirrorImage_RDY = false;
					_Queue = _Queue + 1;
					break;
				end

				if _Evocation_RDY and _ArcaneSurge_RDY and _TouchoftheMagi_RDY and ConRO:FullMode(_Evocation) then
					tinsert(ConRO.SuggestedSpells, _Evocation);
					_Evocation_RDY = false;
					_SiphonStorm_BUFF = true;
					_Clearcasting_COUNT = _Clearcasting_COUNT + 1;
					_Queue = _Queue + 1;
					break;
				end

				if _ArcaneMissiles_RDY and _Clearcasting_COUNT >= 1 then
					tinsert(ConRO.SuggestedSpells, _ArcaneMissiles);
					if tChosen[Ability.NetherPrecision.talentID] then
						_NetherPrecision_BUFF = true;
					end
					_Clearcasting_COUNT = _Clearcasting_COUNT - 1;
					_Queue = _Queue + 1;
					break;
				end
			end

			if _ArcaneBarrage_RDY and _ArcaneCharges >= 4 and (_TouchoftheMagi_RDY or _TouchoftheMagi_CD <= 1) then
				tinsert(ConRO.SuggestedSpells, _ArcaneBarrage);
				_ArcaneBarrage_RDY = false;
				_ArcaneCharges = 0;
				_Intuition_BUFF = false;
				_Aethervision_COUNT = 0;
				_ArcaneTempo_DUR = 12;
				_Queue = _Queue + 1;
				break;
			end

			if _Evocation_RDY and _ArcaneSurge_RDY and _TouchoftheMagi_RDY and ConRO:FullMode(_Evocation) then
				tinsert(ConRO.SuggestedSpells, _Evocation);
				_Evocation_RDY = false;
				_SiphonStorm_BUFF = true;
				_Clearcasting_COUNT = _Clearcasting_COUNT + 1;
				_Queue = _Queue + 1;
				break;
			end

			if _ArcaneSurge_RDY and currentSpell ~= _ArcaneSurge and (currentSpell == _Evocation or _SiphonStorm_BUFF) and ConRO:FullMode(_ArcaneSurge) then
				tinsert(ConRO.SuggestedSpells, _ArcaneSurge);
				_ArcaneSurge_RDY = false;
				_Queue = _Queue + 1;
				break;
			end

			if _TouchoftheMagi_RDY and ConRO:FullMode(_TouchoftheMagi) then
				tinsert(ConRO.SuggestedSpells, _TouchoftheMagi);
				_TouchoftheMagi_RDY = false;
				_Queue = _Queue + 1;
				break;
			end

			if _ShiftingPower_RDY and (tChosen[Ability.ShiftingShards.talentID] or (_ArcaneSurge_CD >= 30 and _ArcaneSurge_CD <= 75 and not _ArcaneSurge_BUFF and not ConRO:HeroSpec(HeroSpec.Sunfury))) and ConRO:FullMode(_ShiftingPower) then
				tinsert(ConRO.SuggestedSpells, _ShiftingPower);
				_ShiftingPower_RDY = false;
				_Queue = _Queue + 1;
				break;
			end

			if _Supernova_RDY and _UnerringProficiency_COUNT >= 30 and _TouchoftheMagi_DEBUFF and _TouchoftheMagi_DUR <= 3 then
				tinsert(ConRO.SuggestedSpells, _Supernova);
				_Supernova_RDY = false;
				_Queue = _Queue + 1;
				break;
			end

			if _PresenceofMind_RDY and _UnerringProficiency_COUNT <= 28 and _TouchoftheMagi_DEBUFF and _TouchoftheMagi_DUR <= 3 then
				tinsert(ConRO.SuggestedSpells, _PresenceofMind);
				_PresenceofMind_RDY = false;
				_Queue = _Queue + 1;
				break;
			end

			if _ArcaneBlast_RDY and _NetherPrecision_BUFF and _Leydrinker_BUFF and ConRO:HeroSpec(HeroSpec.Spellslinger) and ((ConRO_AutoButton:IsVisible() and _enemies_in_40yrds >= 2) or ConRO_AoEButton:IsVisible()) then
				tinsert(ConRO.SuggestedSpells, _ArcaneBlast);
				_Leydrinker_BUFF = false;
				_NetherPrecision_BUFF = false;
				_ArcaneCharges = _ArcaneCharges + 1;
				_Queue = _Queue + 1;
				break;
			end

			if _ArcaneBlast_RDY and tChosen[Ability.MagisSpark.talentID] and _NetherPrecision_BUFF and _TouchoftheMagi_DUR > 10 and ConRO:HeroSpec(HeroSpec.Spellslinger) and ((ConRO_AutoButton:IsVisible() and _enemies_in_40yrds >= 2) or ConRO_AoEButton:IsVisible()) then
				tinsert(ConRO.SuggestedSpells, _ArcaneBlast);
				_NetherPrecision_BUFF = false;
				_ArcaneCharges = _ArcaneCharges + 1;
				_Queue = _Queue + 1;
				break;
			end

			if _ArcaneMissiles_RDY and _Clearcasting_COUNT >= 3 and _ArcaneSoul_DUR >= 2 then
				tinsert(ConRO.SuggestedSpells, _ArcaneMissiles);
				if tChosen[Ability.NetherPrecision.talentID] then
					_NetherPrecision_BUFF = true;
				end
				_Clearcasting_COUNT = _Clearcasting_COUNT - 1;
				_Queue = _Queue + 1;
				break;
			end

			if _ArcaneBarrage_RDY and _ArcaneSoul_BUFF then
				tinsert(ConRO.SuggestedSpells, _ArcaneBarrage);
				_ArcaneBarrage_RDY = false;
				_ArcaneCharges = 4;
				_Clearcasting_COUNT = _Clearcasting_COUNT + 1;
				_Intuition_BUFF = false;
				_Aethervision_COUNT = 0;
				_ArcaneTempo_DUR = 12;
				_Queue = _Queue + 1;
				break;
			end

			if _ShiftingPower_RDY and _ArcaneSurge_CD >= 30 and _ArcaneSurge_CD <= 75 and not _ArcaneSurge_BUFF and not _ArcaneSoul_BUFF and ConRO:HeroSpec(HeroSpec.Sunfury) and ConRO:FullMode(_ShiftingPower) then
				tinsert(ConRO.SuggestedSpells, _ShiftingPower);
				_ShiftingPower_RDY = false;
				_Queue = _Queue + 1;
				break;
			end

			if _ArcaneMissiles_RDY and _Clearcasting_COUNT >= 1 and not _NetherPrecision_BUFF and ((ConRO_AutoButton:IsVisible() and _enemies_in_40yrds <= 1) or ConRO_SingleButton:IsVisible()) then
				tinsert(ConRO.SuggestedSpells, _ArcaneMissiles);
				if tChosen[Ability.NetherPrecision.talentID] then
					_NetherPrecision_BUFF = true;
				end
				_Clearcasting_COUNT = _Clearcasting_COUNT - 1;
				_Queue = _Queue + 1;
				break;
			end

			if _ArcaneOrb_RDY and _ArcaneCharges < 2 and ConRO.lastSpellId ~= _ArcaneOrb and tChosen[Ability.HighVoltage.talentID] then
				tinsert(ConRO.SuggestedSpells, _ArcaneOrb);
				_ArcaneOrb_RDY = false;
				_ArcaneCharges = _ArcaneCharges + 1;
				_Queue = _Queue + 1;
				break;
			end

			if _ArcaneBarrage_RDY and (_ArcaneCharges >= 4 and _ArcaneOrb_RDY and not _NetherPrecision_BUFF and not _Clearcasting_BUFF) or ((_Intuition_BUFF or _Aethervision_COUNT >= 2) and (_NetherPrecision_BUFF or not _Clearcasting_BUFF)) or _ArcaneTempo_DUR <= 2 or _GloriousIncandescence_BUFF then
				tinsert(ConRO.SuggestedSpells, _ArcaneBarrage);
				_ArcaneBarrage_RDY = false;
				_ArcaneCharges = 0;
				_Intuition_BUFF = false;
				_Aethervision_COUNT = 0;
				_ArcaneTempo_DUR = 12;
				_Queue = _Queue + 1;
				break;
			end

			if _ArcaneMissiles_RDY and _Clearcasting_COUNT >= 1 and not _NetherPrecision_BUFF then
				tinsert(ConRO.SuggestedSpells, _ArcaneMissiles);
				if tChosen[Ability.NetherPrecision.talentID] then
					_NetherPrecision_BUFF = true;
				end
				_Clearcasting_COUNT = _Clearcasting_COUNT - 1;
				_Queue = _Queue + 1;
				break;
			end

			if _ArcaneOrb_RDY and _ArcaneCharges < 4 and ConRO.lastSpellId ~= _ArcaneOrb then
				tinsert(ConRO.SuggestedSpells, _ArcaneOrb);
				_ArcaneOrb_RDY = false;
				_ArcaneCharges = _ArcaneCharges + 1;
				_Queue = _Queue + 1;
				break;
			end

			if _ArcaneExplosion_RDY and _ArcaneCharges <= 0 and ((ConRO_AutoButton:IsVisible() and _enemies_in_10yrds >= 2) or ConRO_AoEButton:IsVisible()) then
				tinsert(ConRO.SuggestedSpells, _ArcaneExplosion);
				_ArcaneCharges = _ArcaneCharges + 2;
				_Queue = _Queue + 1;
				break;
			end

			if _ArcaneBlast_RDY then
				tinsert(ConRO.SuggestedSpells, _ArcaneBlast);
				_ArcaneCharges = _ArcaneCharges + 1;
				_Queue = _Queue + 1;
				break;
			end

			if _ArcaneBarrage_RDY then
				tinsert(ConRO.SuggestedSpells, _ArcaneBarrage);
				_ArcaneBarrage_RDY = false;
				_ArcaneCharges = 0;
				_Intuition_BUFF = false;
				_Aethervision_COUNT = 0;
				_ArcaneTempo_DUR = 12;
				_Queue = _Queue + 1;
				break;
			end

			tinsert(ConRO.SuggestedSpells, 289603); --Waiting Spell Icon
			_Queue = _Queue + 3;
			break;
		end
	until _Queue >= 3;
return nil;
end

function ConRO.Mage.ArcaneDef(_, timeShift, currentSpell, gcd, tChosen, pvpChosen)
	wipe(ConRO.SuggestedDefSpells);
	ConRO:Stats();
	local Ability, Form, Buff, Debuff, PetAbility, PvPTalent = ids.Arc_Ability, ids.Arc_Form, ids.Arc_Buff, ids.Arc_Debuff, ids.Arc_PetAbility, ids.Arc_PvPTalent;

--Abilties
	local _PrismaticBarrier, _PrismaticBarrier_RDY = ConRO:AbilityReady(Ability.PrismaticBarrier, timeShift);
		local _PrismaticBarrier_BUFF = ConRO:Aura(Buff.PrismaticBarrier, timeShift);
	local _IceBlock, _IceBlock_RDY = ConRO:AbilityReady(Ability.IceBlock, timeShift);
	local _MirrorImage, _MirrorImage_RDY = ConRO:AbilityReady(Ability.MirrorImage, timeShift);

--Conditions
	if tChosen[Ability.IceCold.talentID] then
		_IceBlock, _IceBlock_RDY = ConRO:AbilityReady(Ability.IceBlockIC, timeShift);
	end

--Rotations	
	if _IceBlock_RDY and _Player_Percent_Health <= 25 and _in_combat then
		tinsert(ConRO.SuggestedDefSpells, _IceBlock);
	end

	if _PrismaticBarrier_RDY and not _PrismaticBarrier_BUFF then
		tinsert(ConRO.SuggestedDefSpells, _PrismaticBarrier);
	end

	if _MirrorImage_RDY and _in_combat then
		tinsert(ConRO.SuggestedDefSpells, _MirrorImage);
	end
return nil;
end

function ConRO.Mage.Fire(_, timeShift, currentSpell, gcd, tChosen, pvpChosen)
	wipe(ConRO.SuggestedSpells);
	ConRO:Stats();
	local Ability, Form, Buff, Debuff, PetAbility, PvPTalent = ids.Fire_Ability, ids.Fire_Form, ids.Fire_Buff, ids.Fire_Debuff, ids.Fire_PetAbility, ids.Fire_PvPTalent;

--Abilities
	local _ArcaneIntellect, _ArcaneIntellect_RDY = ConRO:AbilityReady(Ability.ArcaneIntellect, timeShift);
	local _Blink, _Blink_RDY = ConRO:AbilityReady(Ability.Blink, timeShift);
	local _Combustion, _Combustion_RDY, _Combustion_CD = ConRO:AbilityReady(Ability.Combustion, timeShift);
		local _Combustion_BUFF, _, _Combustion_DUR = ConRO:Aura(Buff.Combustion, timeShift);
	local _Counterspell,  _Counterspell_RDY = ConRO:AbilityReady(Ability.Counterspell, timeShift);
	local _FireBlast, _FireBlast_RDY = ConRO:AbilityReady(Ability.FireBlast, timeShift);
		local _FireBlast_CHARGES, _FireBlast_MCHARGES = 1, 1;
	local _Fireball, _Fireball_RDY = ConRO:AbilityReady(Ability.Fireball, timeShift);
		local _FlameAccelerant_BUFF = ConRO:Aura(Buff.FlameAccelerant, timeShift);
		local _FrostfireEmpowerment_BUFF = ConRO:Aura(Buff.FrostfireEmpowerment, timeShift);
		local _HeatingUp_BUFF = ConRO:Aura(Buff.HeatingUp, timeShift);
		local _HotStreak_BUFF = ConRO:Aura(Buff.HotStreak, timeShift);
	local _Meteor, _Meteor_RDY = ConRO:AbilityReady(Ability.Meteor, timeShift);
	local _MirrorImage, _MirrorImage_RDY = ConRO:AbilityReady(Ability.MirrorImage, timeShift);
	local _Pyroblast, _Pyroblast_RDY = ConRO:AbilityReady(Ability.Pyroblast, timeShift);
		local _FuryoftheSunKing_BUFF = ConRO:Aura(Buff.FuryoftheSunKing, timeShift);
		local _Hyperthermia_BUFF = ConRO:Aura(Buff.Hyperthermia, timeShift);
	local _PhoenixFlames, _PhoenixFlames_RDY = ConRO:AbilityReady(Ability.PhoenixFlames, timeShift);
		local _PhoenixFlames_CHARGES, _PhoenixFlames_MCHARGES, _PhoenixFlames_CCD = ConRO:SpellCharges(_PhoenixFlames);
		local _ExcessFrost_BUFF = ConRO:Aura(Buff.ExcessFrost, timeShift);
		local _FlamesFury_BUFF = ConRO:Aura(Buff.FlamesFury, timeShift);
	local _Scorch, _Scorch_RDY = ConRO:AbilityReady(Ability.Scorch, timeShift);
		local _HeatShimmer_BUFF = ConRO:Aura(Buff.HeatShimmer, timeShift);
	local _ShiftingPower, _ShiftingPower_RDY = ConRO:AbilityReady(Ability.ShiftingPower, timeShift);
	local _Spellsteal, _Spellsteal_RDY = ConRO:AbilityReady(Ability.Spellsteal, timeShift);

--Conditions
	if tChosen[Ability.Shimmer.talentID] then
		_Blink, _Blink_RDY = ConRO:AbilityReady(Ability.Shimmer, timeShift);
	end

	if tChosen[Ability.FireBlast_Fire.talentID] then
		_FireBlast, _FireBlast_RDY = ConRO:AbilityReady(Ability.FireBlast_Fire, timeShift);
		_FireBlast_CHARGES, _FireBlast_MCHARGES = ConRO:SpellCharges(_FireBlast);
	end

	if ConRO:HeroSpec(HeroSpec.Frostfire) and tChosen[Ability.FrostfireBolt.talentID] then
		_Fireball, _Fireball_RDY = ConRO:AbilityReady(Ability.FrostfireBolt, timeShift);
	end

	if tChosen[Ability.MajestyofthePhoenix.talentID] and (tChosen[Ability.Quickflame.talentID] or tChosen[Ability.FlamePatch.talentID]) then
		if (_FuryoftheSunKing_BUFF and not _HotStreak_BUFF and ((ConRO_AutoButton:IsVisible() and _enemies_in_40yrds >= 4) or ConRO_AoEButton:IsVisible())) or ((ConRO_AutoButton:IsVisible() and _enemies_in_40yrds >= 6) or ConRO_AoEButton:IsVisible()) then
			_Pyroblast, _Pyroblast_RDY = ConRO:AbilityReady(Ability.Flamestrike, timeShift);
		end
	end

--Indicators	
	ConRO:AbilityInterrupt(_Counterspell, _Counterspell_RDY and ConRO:Interrupt());
	ConRO:AbilityPurge(_Spellsteal, _Spellsteal_RDY and ConRO:Purgable());
	ConRO:AbilityPurge(_ArcaneTorrent, _ArcaneTorrent_RDY and _target_in_10yrds and ConRO:Purgable());
	ConRO:AbilityMovement(_Blink, _Blink_RDY and _target_in_melee);

	ConRO:AbilityRaidBuffs(_ArcaneIntellect, _ArcaneIntellect_RDY and not ConRO:RaidBuff(Buff.ArcaneIntellect));

	ConRO:AbilityBurst(_Combustion, _Combustion_RDY and (_HotStreak_BUFF or _FuryoftheSunKing_BUFF) and (currentSpell == _Fireball or currentSpell == _Scorch or currentSpell == _Pyroblast) and ConRO:BurstMode(_Combustion));
	ConRO:AbilityBurst(_Meteor, _Meteor_RDY and _Combustion_RDY and (_HotStreak_BUFF or _FuryoftheSunKing_BUFF) and ConRO:BurstMode(_Meteor));
	ConRO:AbilityBurst(_ShiftingPower, _ShiftingPower_RDY and _Combustion_CD >= 20 and _FireBlast_CHARGES < _FireBlast_MCHARGES and _PhoenixFlames_CHARGES < _PhoenixFlames_MCHARGES and ConRO:BurstMode(_ShiftingPower));

--Warnings	

--Rotations
	repeat
		while(true) do
			if select(8, UnitChannelInfo("player")) == _ShiftingPower and _FireBlast_RDY and _FireBlast_CHARGES >= _FireBlast_MCHARGES then
				tinsert(ConRO.SuggestedSpells, _FireBlast);
				_FireBlast_CHARGES = _FireBlast_CHARGES - 1;
				_Queue = _Queue + 1;
				break;
			end

			if select(8, UnitChannelInfo("player")) == _ShiftingPower then
				tinsert(ConRO.SuggestedSpells, _ShiftingPower);
				_ShiftingPower = 0;
				_Queue = _Queue + 1;
				break;
			end

			if not _in_combat then
				if _MirrorImage_RDY and not (_is_PvP or ConRO_PvPButton:IsVisible()) and ConRO:FullMode(_MirrorImage) then
					tinsert(ConRO.SuggestedSpells, _MirrorImage);
					_MirrorImage_RDY = false;
					_Queue = _Queue + 1;
					break;
				end

				if _Pyroblast_RDY and currentSpell ~= _Pyroblast then
					tinsert(ConRO.SuggestedSpells, _Pyroblast);
					_Pyroblast_RDY = false;
					_Queue = _Queue + 1;
					break;
				end

				if _PhoenixFlames_RDY and _PhoenixFlames_CHARGES >= 1 then
					tinsert(ConRO.SuggestedSpells, _PhoenixFlames);
					_PhoenixFlames_RDY = false;
					_PhoenixFlames_CHARGES = _PhoenixFlames_CHARGES - 1;
					if _HeatingUp_BUFF then
						_HotStreak_BUFF = true;
						_HeatingUp_BUFF = false;
					elseif not _HotStreak_BUFF and not _HeatingUp_BUFF then
						_HeatingUp_BUFF = true;
					end
					_Queue = _Queue + 1;
					break;
				end
			end

			if _Combustion_BUFF then
				if _Meteor_RDY and _Combustion_DUR >= 4 and ConRO:FullMode(_Meteor) then
					tinsert(ConRO.SuggestedSpells, _Meteor);
					_Meteor_RDY = false;
					_Queue = _Queue + 1;
					break;
				end

				if _Pyroblast_RDY and (_HotStreak_BUFF or _FuryoftheSunKing_BUFF) then
					tinsert(ConRO.SuggestedSpells, _Pyroblast);
					_FuryoftheSunKing_BUFF = false;
					_HotStreak_BUFF = false;
					_Queue = _Queue + 1;
					break;
				end

				if _PhoenixFlames_RDY and _PhoenixFlames_CHARGES >= 1 and _FlamesFury_BUFF and not _HotStreak_BUFF then
					tinsert(ConRO.SuggestedSpells, _PhoenixFlames);
					_PhoenixFlames_RDY = false;
					if not _FlamesFury_BUFF then
						_PhoenixFlames_CHARGES = _PhoenixFlames_CHARGES - 1;
					end
					_FlamesFury_BUFF = false;
					if _HeatingUp_BUFF then
						_HotStreak_BUFF = true;
						_HeatingUp_BUFF = false;
					elseif not _HotStreak_BUFF and not _HeatingUp_BUFF then
						_HeatingUp_BUFF = true;
					end
					_Queue = _Queue + 1;
					break;
				end

				if _Scorch_RDY and _HeatShimmer_BUFF then
					tinsert(ConRO.SuggestedSpells, _Scorch);
					_HeatShimmer_BUFF = false;
					if _HeatingUp_BUFF then
						_HotStreak_BUFF = true;
						_HeatingUp_BUFF = false;
					elseif not _HotStreak_BUFF and not _HeatingUp_BUFF then
						_HeatingUp_BUFF = true;
					end
					_Queue = _Queue + 1;
					break;
				end

				if _FireBlast_RDY and _FireBlast_CHARGES >= 1 and _HeatingUp_BUFF then
					tinsert(ConRO.SuggestedSpells, _FireBlast);
					_FireBlast_RDY = false;
					_FireBlast_CHARGES = _FireBlast_CHARGES - 1;
					if _HeatingUp_BUFF then
						_HotStreak_BUFF = true;
						_HeatingUp_BUFF = false;
					elseif not _HotStreak_BUFF and not _HeatingUp_BUFF then
						_HeatingUp_BUFF = true;
					end
					_Queue = _Queue + 1;
					break;
				end

				if _Fireball_RDY and _FrostfireEmpowerment_BUFF and not _ExcessFrost_BUFF then
					tinsert(ConRO.SuggestedSpells, _Fireball);
					_FlameAccelerant_BUFF = false;
					if _HeatingUp_BUFF then
						_HotStreak_BUFF = true;
						_HeatingUp_BUFF = false;
					elseif not _HotStreak_BUFF and not _HeatingUp_BUFF then
						_HeatingUp_BUFF = true;
					end
					_Queue = _Queue + 1;
					break;
				end

				if _PhoenixFlames_RDY and _PhoenixFlames_CHARGES >= 1 and not _HotStreak_BUFF then
					tinsert(ConRO.SuggestedSpells, _PhoenixFlames);
					_PhoenixFlames_RDY = false;
					_PhoenixFlames_CHARGES = _PhoenixFlames_CHARGES - 1;
					if _HeatingUp_BUFF then
						_HotStreak_BUFF = true;
						_HeatingUp_BUFF = false;
					elseif not _HotStreak_BUFF and not _HeatingUp_BUFF then
						_HeatingUp_BUFF = true;
					end
					_Queue = _Queue + 1;
					break;
				end

				if _Fireball_RDY and _FlameAccelerant_BUFF then
					tinsert(ConRO.SuggestedSpells, _Fireball);
					_FlameAccelerant_BUFF = false;
					if _HeatingUp_BUFF then
						_HotStreak_BUFF = true;
						_HeatingUp_BUFF = false;
					elseif not _HotStreak_BUFF and not _HeatingUp_BUFF then
						_HeatingUp_BUFF = true;
					end
					_Queue = _Queue + 1;
					break;
				end

				if _Scorch_RDY then
					tinsert(ConRO.SuggestedSpells, _Scorch);
					if _HeatingUp_BUFF then
						_HotStreak_BUFF = true;
						_HeatingUp_BUFF = false;
					elseif not _HotStreak_BUFF and not _HeatingUp_BUFF then
						_HeatingUp_BUFF = true;
					end
					_Queue = _Queue + 1;
					break;
				end
			end

			if tChosen[Ability.Firestarter.talentID] and _Target_Percent_Health >= 90 then
				if _Pyroblast_RDY and _HotStreak_BUFF and (currentSpell == _Pyroblast or currentSpell == _Fireball) then
					tinsert(ConRO.SuggestedSpells, _Pyroblast);
					_HotStreak_BUFF = false;
					_Queue = _Queue + 1;
					break;
				end

				if _FireBlast_RDY and _FireBlast_CHARGES >= 1 and _HeatingUp_BUFF then
					tinsert(ConRO.SuggestedSpells, _FireBlast);
					_FireBlast_RDY = false;
					_FireBlast_CHARGES = _FireBlast_CHARGES - 1;
					_HotStreak_BUFF = true;
					_HeatingUp_BUFF = false;
					_Queue = _Queue + 1;
					break;
				end

				if _PhoenixFlames_RDY and _PhoenixFlames_CHARGES >= 1 and not _HotStreak_BUFF then
					tinsert(ConRO.SuggestedSpells, _PhoenixFlames);
					_PhoenixFlames_RDY = false;
					_PhoenixFlames_CHARGES = _PhoenixFlames_CHARGES - 1;
					if _HeatingUp_BUFF then
						_HotStreak_BUFF = true;
						_HeatingUp_BUFF = false;
					elseif not _HotStreak_BUFF and not _HeatingUp_BUFF then
						_HeatingUp_BUFF = true;
					end
					_Queue = _Queue + 1;
					break;
				end

				if _Fireball_RDY then
					tinsert(ConRO.SuggestedSpells, _Fireball);
					if _HeatingUp_BUFF then
						_HotStreak_BUFF = true;
						_HeatingUp_BUFF = false;
					elseif not _HotStreak_BUFF and not _HeatingUp_BUFF then
						_HeatingUp_BUFF = true;
					end
					_Queue = _Queue + 1;
					break;
				end
			end

			if _FireBlast_RDY and _Hyperthermia_BUFF and _FireBlast_CHARGES >= _FireBlast_MCHARGES and _HeatingUp_BUFF then
				tinsert(ConRO.SuggestedSpells, _FireBlast);
				_FireBlast_RDY = false;
				_FireBlast_CHARGES = _FireBlast_CHARGES - 1;
				_HotStreak_BUFF = true;
				_HeatingUp_BUFF = false;
				_Queue = _Queue + 1;
				break;
			end

			if _ShiftingPower_RDY and _Combustion_CD >= 20 and _FireBlast_CHARGES < _FireBlast_MCHARGES and _PhoenixFlames_CHARGES < _PhoenixFlames_MCHARGES and ConRO:FullMode(_ShiftingPower) then
				tinsert(ConRO.SuggestedSpells, _ShiftingPower);
				_Queue = _Queue + 1;
				break;
			end

			if _Meteor_RDY and _Combustion_RDY and (_HotStreak_BUFF or _FuryoftheSunKing_BUFF) and ConRO:FullMode(_Meteor) then
				tinsert(ConRO.SuggestedSpells, _Meteor);
				_Meteor_RDY = false;
				_Queue = _Queue + 1;
				break;
			end

			if _Combustion_RDY and (_HotStreak_BUFF or _FuryoftheSunKing_BUFF) and (currentSpell == _Fireball or currentSpell == _Scorch or currentSpell == _Pyroblast) and ConRO:FullMode(_Combustion) then
				tinsert(ConRO.SuggestedSpells, _Combustion);
				_Combustion_RDY = false;
				_Queue = _Queue + 1;
				break;
			end

			if _Pyroblast_RDY and ((_HotStreak_BUFF and (currentSpell == _Pyroblast or currentSpell == _Fireball or currentSpell == _Scorch)) or _FuryoftheSunKing_BUFF or _Hyperthermia_BUFF) then
				tinsert(ConRO.SuggestedSpells, _Pyroblast);
				_FuryoftheSunKing_BUFF = false;
				_HotStreak_BUFF = false;
				_Queue = _Queue + 1;
				break;
			end

			if _Scorch_RDY and _HeatShimmer_BUFF then
				tinsert(ConRO.SuggestedSpells, _Scorch);
				_HeatShimmer_BUFF = false;
				if _HeatingUp_BUFF then
					_HotStreak_BUFF = true;
					_HeatingUp_BUFF = false;
				elseif not _HotStreak_BUFF and not _HeatingUp_BUFF then
					_HeatingUp_BUFF = true;
				end
				_Queue = _Queue + 1;
				break;
			end

			if _FireBlast_RDY and _FireBlast_CHARGES >= 1 and _HeatingUp_BUFF and currentSpell then
				tinsert(ConRO.SuggestedSpells, _FireBlast);
				_FireBlast_RDY = false;
				_FireBlast_CHARGES = _FireBlast_CHARGES - 1;
				_HotStreak_BUFF = true;
				_HeatingUp_BUFF = false;
				_Queue = _Queue + 1;
				break;
			end

			if _Fireball_RDY and _FrostfireEmpowerment_BUFF and not _ExcessFrost_BUFF then
				tinsert(ConRO.SuggestedSpells, _Fireball);
				_FlameAccelerant_BUFF = false;
				if _HeatingUp_BUFF then
					_HotStreak_BUFF = true;
					_HeatingUp_BUFF = false;
				elseif not _HotStreak_BUFF and not _HeatingUp_BUFF then
					_HeatingUp_BUFF = true;
				end
				_Queue = _Queue + 1;
				break;
			end

			if _PhoenixFlames_RDY and _PhoenixFlames_CHARGES >= 1 and not _HotStreak_BUFF then
				tinsert(ConRO.SuggestedSpells, _PhoenixFlames);
				_PhoenixFlames_RDY = false;
				_PhoenixFlames_CHARGES = _PhoenixFlames_CHARGES - 1;
				if _HeatingUp_BUFF then
					_HotStreak_BUFF = true;
					_HeatingUp_BUFF = false;
				elseif not _HotStreak_BUFF and not _HeatingUp_BUFF then
					_HeatingUp_BUFF = true;
				end
				_Queue = _Queue + 1;
				break;
			end

			if _DragonsBreath_RDY and _target_in_10yrds and _HeatingUp_BUFF and tChosen[Ability.AlexstraszasFury.talentID] then
				tinsert(ConRO.SuggestedSpells, _DragonsBreath);
				_DragonsBreath_RDY = false;
				_Queue = _Queue + 1;
				break;
			end

			if _Scorch_RDY and (_Target_Percent_Health <= 30 or _is_moving) then
				tinsert(ConRO.SuggestedSpells, _Scorch);
				if _HeatingUp_BUFF then
					_HotStreak_BUFF = true;
					_HeatingUp_BUFF = false;
				elseif not _HotStreak_BUFF and not _HeatingUp_BUFF then
					_HeatingUp_BUFF = true;
				end
				_Queue = _Queue + 1;
				break;
			end

			if _Fireball_RDY then
				tinsert(ConRO.SuggestedSpells, _Fireball);
				_Queue = _Queue + 1;
				break;
			end

			tinsert(ConRO.SuggestedSpells, 289603); --Waiting Spell Icon
			_Queue = _Queue + 3;
			break;
		end
	until _Queue >= 3;
return nil;
end

function ConRO.Mage.FireDef(_, timeShift, currentSpell, gcd, tChosen, pvpChosen)
	wipe(ConRO.SuggestedDefSpells);
	ConRO:Stats();
	local Ability, Form, Buff, Debuff, PetAbility, PvPTalent = ids.Fire_Ability, ids.Fire_Form, ids.Fire_Buff, ids.Fire_Debuff, ids.Fire_PetAbility, ids.Fire_PvPTalent;

--Abilities	
	local _BlazingBarrier, _BlazingBarrier_RDY = ConRO:AbilityReady(Ability.BlazingBarrier, timeShift);
		local _BlazingBarrier_BUFF = ConRO:Aura(Buff.BlazingBarrier, timeShift);
	local _IceBlock, _IceBlock_RDY = ConRO:AbilityReady(Ability.IceBlock, timeShift);
	local _MirrorImage, _MirrorImage_RDY = ConRO:AbilityReady(Ability.MirrorImage, timeShift);

--Conditions
	if tChosen[Ability.IceCold.talentID] then
		_IceBlock, _IceBlock_RDY = ConRO:AbilityReady(Ability.IceBlockIC, timeShift);
	end

--Rotations	
	if _IceBlock_RDY and _Player_Percent_Health <= 25 and _in_combat then
		tinsert(ConRO.SuggestedDefSpells, _IceBlock);
	end

	if _BlazingBarrier_RDY and not _BlazingBarrier_BUFF then
		tinsert(ConRO.SuggestedDefSpells, _BlazingBarrier);
	end

	if _MirrorImage_RDY and _in_combat then
		tinsert(ConRO.SuggestedDefSpells, _MirrorImage);
	end
return nil;
end

function ConRO.Mage.Frost(_, timeShift, currentSpell, gcd, tChosen, pvpChosen)
	wipe(ConRO.SuggestedSpells);
	ConRO:Stats();
	local Ability, Form, Buff, Debuff, PetAbility, PvPTalent = ids.Frost_Ability, ids.Frost_Form, ids.Frost_Buff, ids.Frost_Debuff, ids.Frost_PetAbility, ids.Frost_PvPTalent;

--Abilities
	local _ArcaneIntellect, _ArcaneIntellect_RDY = ConRO:AbilityReady(Ability.ArcaneIntellect, timeShift);
	local _Blink, _Blink_RDY = ConRO:AbilityReady(Ability.Blink, timeShift);
	local _Blizzard, _Blizzard_RDY = ConRO:AbilityReady(Ability.Blizzard, timeShift);
		local _FreezingRain_BUFF = ConRO:Aura(Buff.FreezingRain, timeShift);
	local _CometStorm, _CometStorm_RDY, _CometStorm_CD = ConRO:AbilityReady(Ability.CometStorm, timeShift);
	local _ConeofCold, _ConeofCold_RDY = ConRO:AbilityReady(Ability.ConeofCold, timeShift);
	local _Counterspell, _Counterspell_RDY = ConRO:AbilityReady(Ability.Counterspell, timeShift);
	local _Flurry, _Flurry_RDY, _Flurry_CD = ConRO:AbilityReady(Ability.Flurry, timeShift);
		local _BrainFreeze_BUFF = ConRO:Aura(Buff.BrainFreeze, timeShift);
		local _, _WintersChill_COUNT = ConRO:TargetAura(Debuff.WintersChill, timeShift);
	local _Frostbolt, _Frostbolt_RDY = ConRO:AbilityReady(Ability.Frostbolt, timeShift);
		local _ExcessFire_BUFF = ConRO:Aura(Buff.ExcessFire, timeShift);
	local _FrozenOrb, _FrozenOrb_RDY, _FrozenOrb_CD = ConRO:AbilityReady(Ability.FrozenOrb, timeShift);
		local _ConcentratedCoolness_FrozenOrb, _, _ConcentratedCoolness_FrozenOrb_CD = ConRO:AbilityReady(PvPTalent.ConcentratedCoolness_FrozenOrb, timeShift);
	local _GlacialSpike, _GlacialSpike_RDY = ConRO:AbilityReady(Ability.GlacialSpike, timeShift);
	local _IceFloes, _IceFloes_RDY = ConRO:AbilityReady(Ability.IceFloes, timeShift);
	local _IceForm, _, _IceForm_CD = ConRO:AbilityReady(PvPTalent.IceForm, timeShift);
	local _IceLance, _IceLance_RDY = ConRO:AbilityReady(Ability.IceLance, timeShift);
		local _, _Icicles_COUNT = ConRO:Aura(Buff.Icicles, timeShift);
		local _, _FingersofFrost_COUNT = ConRO:Aura(Buff.FingersofFrost, timeShift);
	local _IceNova, _IceNova_RDY = ConRO:AbilityReady(Ability.IceNova, timeShift);
	local _IcyVeins, _IcyVeins_RDY, _IcyVeins_CD = ConRO:AbilityReady(Ability.IcyVeins, timeShift);
		local _IcyVeins_BUFF, _, _IcyVeins_DUR = ConRO:Aura(Buff.IcyVeins, timeShift);
		local _, _DeathsChill_COUNT = ConRO:Form(Form.DeathsChill);
	local _MirrorImage, _MirrorImage_RDY = ConRO:AbilityReady(Ability.MirrorImage, timeShift);
	local _RayofFrost, _RayofFrost_RDY = ConRO:AbilityReady(Ability.RayofFrost, timeShift);
	local _ShiftingPower, _ShiftingPower_RDY = ConRO:AbilityReady(Ability.ShiftingPower, timeShift);
	local _Spellsteal, _Spellsteal_RDY = ConRO:AbilityReady(Ability.Spellsteal, timeShift);
	local _TimeWarp, _TimeWarp_RDY = ConRO:AbilityReady(Ability.TimeWarp, timeShift);
		local _TemporalDisplacement_DEBUFF = ConRO:Aura(Debuff.TemporalDisplacement, timeShift, "HARMFUL");
		local _TimeWarp_BUFF, _TemporalDisplacement = ConRO:Heroism();

--Conditions
	local _enemies_in_15yrds, _target_in_15yrds = ConRO:Targets("15");

	local _Pet_summoned = ConRO:CallPet();
	local _Pet_assist = ConRO:PetAssist();

	if tChosen[Ability.Shimmer.talentID] then
		_Blink, _Blink_RDY = ConRO:AbilityReady(Ability.Shimmer, timeShift);
	end

	if ConRO:HeroSpec(HeroSpec.Frostfire) and tChosen[Ability.FrostfireBolt.talentID] then
		_Frostbolt, _Frostbolt_RDY = ConRO:AbilityReady(Ability.FrostfireBolt, timeShift);
	end

	if currentSpell == _Frostbolt then
		_Icicles_COUNT = _Icicles_COUNT + 1;
	elseif currentSpell == _GlacialSpike then
		_Icicles_COUNT = 0;
	end

	if currentSpell == _GlacialSpike or currentSpell == _RayofFrost or currentSpell == _Frostbolt then
		_WintersChill_COUNT = _WintersChill_COUNT - 1;
	end

	if _is_PvP then
		if pvpChosen[PvPTalent.IceForm.spellID] then
			_IcyVeins_RDY = _IcyVeins_RDY and _IceForm_CD <= 0
			_IcyVeins = _IceForm;
		end
		if pvpChosen[PvPTalent.ConcentratedCoolness.spellID] then
			_FrozenOrb_RDY = _FrozenOrb_RDY and _ConcentratedCoolness_FrozenOrb_CD <= 0;
			_FrozenOrb = _ConcentratedCoolness_FrozenOrb;
			_FrozenOrb_CD = _ConcentratedCoolness_FrozenOrb_CD;
		end
	end

--Indicators	
	ConRO:AbilityInterrupt(_Counterspell, _Counterspell_RDY and ConRO:Interrupt());
	ConRO:AbilityPurge(_Spellsteal, _Spellsteal_RDY and ConRO:Purgable());
	ConRO:AbilityPurge(_ArcaneTorrent, _ArcaneTorrent_RDY and _target_in_10yrds and ConRO:Purgable());
	ConRO:AbilityMovement(_Blink, _Blink_RDY and _target_in_melee);

	ConRO:AbilityRaidBuffs(_ArcaneIntellect, _ArcaneIntellect_RDY and not ConRO:RaidBuff(Buff.ArcaneIntellect));

	ConRO:AbilityBurst(_FrozenOrb, _FrozenOrb_RDY and ConRO:BurstMode(_FrozenOrb));
	ConRO:AbilityBurst(_IcyVeins, _in_combat and _IcyVeins_RDY and ConRO:BurstMode(_IcyVeins));
	ConRO:AbilityBurst(_FrozenOrb, _in_combat and _FrozenOrb_RDY and ((ConRO_AutoButton:IsVisible() and _enemies_in_40yrds >= 3) or ConRO_AoEButton:IsVisible()) and not _RayofFrost_RDY and ConRO:BurstMode(_FrozenOrb));
	ConRO:AbilityBurst(_RayofFrost, _in_combat and _RayofFrost_RDY and ((ConRO_AutoButton:IsVisible() and _enemies_in_40yrds <= 1) or ConRO_SingleButton:IsVisible()) and _WintersChill_COUNT == 1 and ConRO:BurstMode(_RayofFrost));
	ConRO:AbilityBurst(_ShiftingPower, _in_combat and _ShiftingPower_RDY and _enemies_in_15yrds >= 3 and currentSpell ~= _ShiftingPower and ConRO:BurstMode(_ShiftingPower));

--Warnings	

--Rotations	
	repeat
		while(true) do
			if select(8, UnitChannelInfo("player")) == _ShiftingPower then
				tinsert(ConRO.SuggestedSpells, _ShiftingPower);
				_ShiftingPower = 0;
				_Queue = _Queue + 1;
				break;
			end

			if not _in_combat then
				if _MirrorImage_RDY and not (_is_PvP or ConRO_PvPButton:IsVisible()) and ConRO:FullMode(_MirrorImage) then
					tinsert(ConRO.SuggestedSpells, _MirrorImage);
					_MirrorImage_RDY = false;
					_Queue = _Queue + 1;
					break;
				end

				if _Frostbolt_RDY and currentSpell ~= _Frostbolt then
					tinsert(ConRO.SuggestedSpells, _Frostbolt);
					_Frostbolt_RDY = false;
					_WintersChill_COUNT = _WintersChill_COUNT - 1;
					_Icicles_COUNT = _Icicles_COUNT + 1;
					_Queue = _Queue + 1;
					break;
				end

				if _Flurry_RDY and _WintersChill_COUNT <= 0 then
					tinsert(ConRO.SuggestedSpells, _Flurry);
					_Flurry_RDY = false;
					_WintersChill_COUNT = 2;
					_Icicles_COUNT = _Icicles_COUNT + 1;
					_Queue = _Queue + 1;
					break;
				end
			end

			if _IcyVeins_RDY and ConRO:FullMode(_IcyVeins) then
				tinsert(ConRO.SuggestedSpells, _IcyVeins);
				_IcyVeins_RDY = false;
				_IcyVeins_BUFF = true;
				_Queue = _Queue + 1;
				break;
			end

			if _ConeofCold_RDY and tChosen[Ability.ColdestSnap.talentID] and _enemies_in_15yrds >= 3 and not _FrozenOrb_RDY and not _CometStorm_RDY then
				tinsert(ConRO.SuggestedSpells, _ConeofCold);
				_ConeofCold_RDY = false;
				_CometStorm_RDY = true;
				_FrozenOrb_RDY = true;
				_WintersChill_COUNT = 2;
				_Queue = _Queue + 1;
				break;
			end

			if _CometStorm_RDY and _WintersChill_COUNT > 1 and ((ConRO_AutoButton:IsVisible() and _enemies_in_40yrds <= 1) or ConRO_SingleButton:IsVisible()) then
				tinsert(ConRO.SuggestedSpells, _CometStorm);
				_CometStorm_RDY = false;
				_WintersChill_COUNT = _WintersChill_COUNT - 1;
				_Queue = _Queue + 1;
				break;
			end

			if _Flurry_RDY and _WintersChill_COUNT <= 0 and ((not tChosen[Ability.DeathsChill.talentID] and currentSpell == _Frostbolt) or currentSpell == _GlacialSpike) then
				tinsert(ConRO.SuggestedSpells, _Flurry);
				_Flurry_RDY = false;
				_WintersChill_COUNT = 2;
				_Icicles_COUNT = _Icicles_COUNT + 1;
				_Queue = _Queue + 1;
				break;
			end

			if (_GlacialSpike_RDY or (_Icicles_COUNT >= 5 and tChosen[Ability.GlacialSpike.talentID])) and (_WintersChill_COUNT >= 1 or _Flurry_RDY) and currentSpell ~= _GlacialSpike and tChosen[Ability.DeathsChill.talentID] and ((ConRO_AutoButton:IsVisible() and _enemies_in_40yrds <= 1) or ConRO_SingleButton:IsVisible()) then
				tinsert(ConRO.SuggestedSpells, _GlacialSpike);
				_GlacialSpike_RDY = false;
				_Icicles_COUNT = 0;
				_WintersChill_COUNT = _WintersChill_COUNT - 1;
				_Queue = _Queue + 1;
				break;
			end

			if _RayofFrost_RDY and (_WintersChill_COUNT == 1 or (ConRO.lastSpellId == _IceLance and _WintersChill_COUNT == 2)) and tChosen[Ability.DeathsChill.talentID] and ((ConRO_AutoButton:IsVisible() and _enemies_in_40yrds <= 1) or ConRO_SingleButton:IsVisible()) and ConRO:FullMode(_RayofFrost) then
				tinsert(ConRO.SuggestedSpells, _RayofFrost);
				_RayofFrost_RDY = false;
				_WintersChill_COUNT = _WintersChill_COUNT - 1;
				_Queue = _Queue + 1;
				break;
			end

			if _FrozenOrb_RDY and ConRO:FullMode(_FrozenOrb) then
				tinsert(ConRO.SuggestedSpells, _FrozenOrb);
				_FrozenOrb_RDY = false;
				_Queue = _Queue + 1;
				break;
			end

			if _Frostbolt_RDY and _IcyVeins_BUFF and _IcyVeins_DUR >= 8 and _DeathsChill_COUNT < 14 and ((ConRO_AutoButton:IsVisible() and _enemies_in_40yrds >= 3) or ConRO_AoEButton:IsVisible()) then
				tinsert(ConRO.SuggestedSpells, _Frostbolt);
				_Icicles_COUNT = _Icicles_COUNT + 1;
				_Queue = _Queue + 1;
				break;
			end

			if _CometStorm_RDY and ((ConRO_AutoButton:IsVisible() and _enemies_in_40yrds >= 3) or ConRO_AoEButton:IsVisible()) then
				tinsert(ConRO.SuggestedSpells, _CometStorm);
				_CometStorm_RDY = false;
				_WintersChill_COUNT = _WintersChill_COUNT - 1;
				_Queue = _Queue + 1;
				break;
			end

			if _Blizzard_RDY and tChosen[Ability.FreezingRain.talentID] and tChosen[Ability.IceCaller.talentID] and currentSpell ~= _Blizzard and ((ConRO_AutoButton:IsVisible() and _enemies_in_40yrds >= 3) or ConRO_AoEButton:IsVisible()) then
				tinsert(ConRO.SuggestedSpells, _Blizzard);
				_Blizzard_RDY = false;
				_Queue = _Queue + 1;
				break;
			end

			if _ShiftingPower_RDY and _FrozenOrb_CD >= 20 and _CometStorm_CD >= 15 and _IcyVeins_CD >= 20 and not _IcyVeins_BUFF and currentSpell ~= _ShiftingPower and ConRO:FullMode(_ShiftingPower) then
				tinsert(ConRO.SuggestedSpells, _ShiftingPower);
				_ShiftingPower_RDY = false;
				_Queue = _Queue + 1;
				break;
			end

			if (_GlacialSpike_RDY or (_Icicles_COUNT >= 5 and tChosen[Ability.GlacialSpike.talentID])) and (_WintersChill_COUNT >= 1 or _Flurry_RDY) and currentSpell ~= _GlacialSpike then
				tinsert(ConRO.SuggestedSpells, _GlacialSpike);
				_GlacialSpike_RDY = false;
				_Icicles_COUNT = 0;
				_WintersChill_COUNT = _WintersChill_COUNT - 1;
				_Queue = _Queue + 1;
				break;
			end

			if _RayofFrost_RDY and (_WintersChill_COUNT == 1 or (ConRO.lastSpellId == _IceLance and _WintersChill_COUNT == 2)) and ((ConRO_AutoButton:IsVisible() and _enemies_in_40yrds <= 1) or ConRO_SingleButton:IsVisible()) and ConRO:FullMode(_RayofFrost) then
				tinsert(ConRO.SuggestedSpells, _RayofFrost);
				_RayofFrost_RDY = false;
				_WintersChill_COUNT = _WintersChill_COUNT - 1;
				_Queue = _Queue + 1;
				break;
			end

			if _IceLance_RDY and _ExcessFire_BUFF and _WintersChill_COUNT >= 2 then
				tinsert(ConRO.SuggestedSpells, _IceLance);
				_ExcessFire_BUFF = false;
				_FingersofFrost_COUNT = _FingersofFrost_COUNT - 1;
				_WintersChill_COUNT = _WintersChill_COUNT - 1;
				_Icicles_COUNT = _Icicles_COUNT + 1;
				_Queue = _Queue + 1;
				break;
			end

			if _Frostbolt_RDY and _IcyVeins_BUFF and _IcyVeins_DUR >= 8 and _DeathsChill_COUNT < 14 then
				tinsert(ConRO.SuggestedSpells, _Frostbolt);
				_Icicles_COUNT = _Icicles_COUNT + 1;
				_Queue = _Queue + 1;
				break;
			end

			if _IceLance_RDY and (ConRO.lastSpellId == _Flurry or _WintersChill_COUNT >= 1 or _FingersofFrost_COUNT >= 1) then
				tinsert(ConRO.SuggestedSpells, _IceLance);
				_FingersofFrost_COUNT = _FingersofFrost_COUNT - 1;
				_WintersChill_COUNT = _WintersChill_COUNT - 1;
				_Icicles_COUNT = _Icicles_COUNT + 1;
				_Queue = _Queue + 1;
				break;
			end

			if _Frostbolt_RDY then
				tinsert(ConRO.SuggestedSpells, _Frostbolt);
				_Icicles_COUNT = _Icicles_COUNT + 1;
				_Queue = _Queue + 1;
				break;
			end

			tinsert(ConRO.SuggestedSpells, 289603); --Waiting Spell Icon
			_Queue = _Queue + 3;
			break;
		end
	until _Queue >= 3;
return nil;
end

function ConRO.Mage.FrostDef(_, timeShift, currentSpell, gcd, tChosen, pvpChosen)
	wipe(ConRO.SuggestedDefSpells);
	ConRO:Stats();
	local Ability, Form, Buff, Debuff, PetAbility, PvPTalent = ids.Frost_Ability, ids.Frost_Form, ids.Frost_Buff, ids.Frost_Debuff, ids.Frost_PetAbility, ids.Frost_PvPTalent;

--Abilities	
	local _IceBarrier, _IceBarrier_RDY = ConRO:AbilityReady(Ability.IceBarrier, timeShift);
		local _IceBarrier_BUFF = ConRO:Aura(Buff.IceBarrier, timeShift);
	local _IceBlock, _IceBlock_RDY = ConRO:AbilityReady(Ability.IceBlock, timeShift);
	local _ColdSnap, _ColdSnap_RDY = ConRO:AbilityReady(Ability.ColdSnap, timeShift);
	local _MirrorImage, _MirrorImage_RDY = ConRO:AbilityReady(Ability.MirrorImage, timeShift);

--Conditions
	if tChosen[Ability.IceCold.talentID] then
		_IceBlock, _IceBlock_RDY = ConRO:AbilityReady(Ability.IceBlockIC, timeShift);
	end

--Rotations	
	if _ColdSnap_RDY and not _IceBlock_RDY then
		tinsert(ConRO.SuggestedDefSpells, _ColdSnap);
	end

	if _IceBlock_RDY and _Player_Percent_Health <= 25 and _in_combat then
		tinsert(ConRO.SuggestedDefSpells, _IceBlock);
	end

	if _IceBarrier_RDY and not _IceBarrier_BUFF then
		tinsert(ConRO.SuggestedDefSpells, _IceBarrier);
	end

	if _MirrorImage_RDY and _in_combat then
		tinsert(ConRO.SuggestedDefSpells, _MirrorImage);
	end
	return nil;
end
extends Node

enum ITEMS {
	ENVELOPES, TRIANGLE, BOX,
	DISGUISE, AXE, BOLT_CUTTERS,
	GUN, BALACLAVA, FAKE_ID,
	KNIFE, KARAOKE, STEAK,
	CHILD, BUNSON_BURNER, MICROSCOPE,
	HOLY_WATER, DOG_COLLAR, BIBLE,
	DRUGS, CADAVER, CONTRACEPTIVES,
	CONTRACT, VIDEO, CAMERA,
}

const ITEM_INFO = {
	ITEMS.ENVELOPES: {
		"label": "Envelopes",
	},
	ITEMS.TRIANGLE: {
		"label": "Triangle",
	},
	ITEMS.BOX: {
		"label": "Cardboard Box",
	},
	ITEMS.DISGUISE: {
		"label": "Fireman's Outfit",
	},
	ITEMS.AXE: {
		"label": "Axe",
	},
	ITEMS.BOLT_CUTTERS: {
		"label": "Bolt Cutters",
	},
	ITEMS.GUN: {
		"label": "Pistol",
	},
	ITEMS.BALACLAVA: {
		"label": "Balaclava",
	},
	ITEMS.FAKE_ID: {
		"label": "Fake ID",
	},
	ITEMS.KNIFE: {
		"label": "Kitchen Knife",
	},
	ITEMS.KARAOKE: {
		"label": "Karaoke Machine",
	},
	ITEMS.STEAK: {
		"label": "Steak, Very Rare",
	},
	ITEMS.CHILD: {
		"label": "School Child",
	}, 
	ITEMS.BUNSON_BURNER: {
		"label": "Bunson Burner",
	}, 
	ITEMS.MICROSCOPE: {
		"label": "Microscope",
	},
	ITEMS.HOLY_WATER: {
		"label": "Holy Water",
	}, 
	ITEMS.DOG_COLLAR: {
		"label": "Dog Collar",
	}, 
	ITEMS.BIBLE: {
		"label": "Bible",
	},
	ITEMS.DRUGS: {
		"label": "Sleeping Pills",
	}, 
	ITEMS.CADAVER: {
		"label": "Cadaver",
	}, 
	ITEMS.CONTRACEPTIVES: {
		"label": "Contraceptives",
	},
	ITEMS.CONTRACT: {
		"label": "Contract",
	}, 
	ITEMS.VIDEO: {
		"label": "Video Tape",
	}, 
	ITEMS.CAMERA: {
		"label": "Video Camera",
	}
}

enum BUILDINGS {
	CHURCH,
	FIRE_STATION,
	HOSPITAL,
	OFFICE,
	POLICE_STATION,
	POST_OFFICE,
	RESTAURANT,
	SCHOOL,
	DEAD_DROP,
}

const BUILDING_INFO = {
	BUILDINGS.CHURCH: {
		"label": "Church",
		"items": [ITEMS.HOLY_WATER, ITEMS.DOG_COLLAR, ITEMS.BIBLE],
	},
	BUILDINGS.FIRE_STATION: {
		"label": "Fire Station",
		"items": [ITEMS.DISGUISE, ITEMS.AXE, ITEMS.BOLT_CUTTERS],
	},
	BUILDINGS.HOSPITAL: {
		"label": "Hospital",
		"items": [ITEMS.DRUGS, ITEMS.CADAVER, ITEMS.CONTRACEPTIVES],
	},
	BUILDINGS.OFFICE: {
		"label": "Office",
		"items": [ITEMS.CONTRACT, ITEMS.VIDEO, ITEMS.CAMERA],
	},
	BUILDINGS.POLICE_STATION: {
		"label": "Police Station",
		"items": [ITEMS.GUN, ITEMS.BALACLAVA, ITEMS.FAKE_ID],
	},
	BUILDINGS.POST_OFFICE: {
		"label": "Post Office",
		"items": [ITEMS.ENVELOPES, ITEMS.TRIANGLE, ITEMS.BOX],
	},
	BUILDINGS.RESTAURANT: {
		"label": "Restaurant",
		"items": [ITEMS.KNIFE, ITEMS.KARAOKE, ITEMS.STEAK],
	},
	BUILDINGS.SCHOOL: {
		"label": "School",
		"items": [ITEMS.CHILD, ITEMS.BUNSON_BURNER, ITEMS.MICROSCOPE],
	},
	BUILDINGS.DEAD_DROP: {
		"label": "",
		"items": [],
	},
}

const MISSIONS = [
	{
		"name": "Summon an Elder God",
		"requirements": [ITEMS.TRIANGLE, ITEMS.KNIFE, ITEMS.CHILD],
		"location": BUILDINGS.CHURCH,
	},
	{
		"name": "Fake Your Own Death",
		"requirements": [ITEMS.GUN, ITEMS.DRUGS, ITEMS.DISGUISE],
		"location": BUILDINGS.OFFICE,
	},
	{
		"name": "Win a Duel with the Devil",
		"requirements": [ITEMS.HOLY_WATER, ITEMS.CONTRACT, ITEMS.KARAOKE],
		"location": BUILDINGS.POST_OFFICE,
	},
	{
		"name": "Burn Down the Fire Station",
		"requirements": [ITEMS.BUNSON_BURNER, ITEMS.ENVELOPES, ITEMS.BALACLAVA],
		"location": BUILDINGS.FIRE_STATION,
	},
	{
		"name": "Cover Up a Murder",
		"requirements": [ITEMS.VIDEO, ITEMS.CADAVER, ITEMS.DOG_COLLAR],
		"location": BUILDINGS.POLICE_STATION,
	},
	{
		"name": "Free the Lobsters",
		"requirements": [ITEMS.AXE, ITEMS.BIBLE, ITEMS.BOX],
		"location": BUILDINGS.RESTAURANT,
	},
	{
		"name": "Distribute Contraceptives",
		"requirements": [ITEMS.CONTRACEPTIVES, ITEMS.BOLT_CUTTERS, ITEMS.FAKE_ID],
		"location": BUILDINGS.SCHOOL,
	},
	{
		"name": "Create a T-Rex",
		"requirements": [ITEMS.MICROSCOPE, ITEMS.STEAK, ITEMS.CAMERA],
		"location": BUILDINGS.HOSPITAL,
	},
]

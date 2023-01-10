--[[
    ÖNEMLİ NOT: Bu komut dosyası, TÜBİTAK kurumunun yarışması çerçevesinde projeye katkı sağlaması amacıyla yazılmış olup projenin simülasyonunu hedefleyen bir çeşit programlama dili içerir. Eğer bu yazıyı görüyorsanız, lütfen proje sahiplerine danışınız.
    
    IMPORTANT NOTE: This script was written to contribute to a project within the framework of the competition of the TÜBİTAK institution (The Scientific and Technological Research Council of Türki̇ye) and comprises a kind of programming language with which project's simulation will be carried out. Should you see this writing please consult with the project's owners.
    
    Oluşturulma Tarihi / Creation Date : +03:00 25/12/2022 16:38
    Yazar / Writer                     : @ProBaturay
--]]

--!strict

local weatherTypes = {
	[1] = {
		[1] = "Parçalı bulutlu",
		[2] = "Bulutlu"
	},
	
	[2] = {
		[1] = "Güneşli",
		[2] = "Parçalı bulutlu"
	},
	
	[3] = {
		[1] = "Hafif yağışlı",
		[2] = "Orta kuvvette yağışlı",
		[3] = "Kuvvetli yağışlı",
	}
}

return {
	[1] = {
		State = "Havadaki bağıl nem oranı yüksek olduğu için tente, uzunluğu boyunca açılmaktadır. Bu, yağmur yağma olasılığının olduğu anlamına gelir.",
		Possibilities = "Yağmur yağmazsa, atıştırırsa veya çiselerse tentenin yanlış zamanda açılmış olması nedeniyle enerji sarfı",
		Reality = {
			SpeedUp = "5 kat",
			Suitable = "Evet",
			Cost = "Orta",
			Actualizable = "Evet"
		},
		Properties = {
			Weather = weatherTypes[1][math.random(1, 2)],
			SoilMoisture = "Bitki için uygun değil.",
			Fullness = "Boş",
			Awning = "Açılıyor"
		},
		Environment = {
			Clouds = {
				Cover = {0.7, 0.9},
				Density = {0.8, 0.9}
			},
			Atmosphere = {
				Density = {0.3, 0.5}
			}
		}
	},
	
	[2] = {
		State = "Yağmur yağdığı farz edilirse açılmış tente, su birikintisini saçağa iletir. Saçaktaki su, depolara dökülür. Toprağının nemi fazla olan bitkilerin yetişememe sorunu ortadan kalkmış olur.",
		Possibilities = "Fazla yağmur sonucunda depoların taşması",
		Reality = {
			SpeedUp = "100 kat",
			Suitable = "Evet",
			Cost = "Uygun",
			Actualizable = "Evet"
		},
		Properties = {
			Weather = weatherTypes[3][math.random(1, 3)],
			SoilMoisture = "Bitki için uygun değil.",
			Fullness = "Doluyor",
			Awning = "Açık"
		},
		Environment = {
			Clouds = {
				Cover = {0.9, 0.9},
				Density = {0.9, 0.9}
			},
			Atmosphere = {
				Density = {0.5, 0.5}
			}
		}
	},
	
	[3] = {
		State = "Yağmur durduğu anda tente eski konumuna getirilir.",
		Possibilities = "Fazla yağmur sonucunda depoların taşması",
		Reality = {
			SpeedUp = "5 kat",
			Suitable = "Evet",
			Cost = "Orta",
			Actualizable = "Evet"
		},
		Properties = {
			Weather = weatherTypes[2][math.random(1, 2)],
			SoilMoisture = "Bitki için uygun değil.",
			Fullness = "Tam dolu",
			Awning = "Kapanıyor"
		},
		Environment = {
			Clouds = {
				Cover = {0.9, 0.5},
				Density = {0.9, 0.8}
			},
			Atmosphere = {
				Density = {0.5, 0.3}
			}
		}
	},
	
	[4] = {
		State = "Toprağa batırılmış olan nem ölçen cihazlarla toprağın nemi ölçülür. Eğer bitkinin yaşaması için elverişli koşullar sağlanmamışsa toprağa su akışı gerçekleşir. Şu anda toprağın nemi düşük olduğu için boruda su geçişi vardır.",
		Possibilities = "Büyük su kütlesinin toprağa verilmesi",
		Reality = {
			SpeedUp = "10 kat",
			Suitable = "Evet",
			Cost = "Uygun",
			Actualizable = "Evet"
		},
		Properties = {
			Weather = weatherTypes[2][math.random(1, 2)],
			SoilMoisture = "Bitki için uygun hâle getiriliyor.",
			Fullness = "Tam dolu",
			Awning = "Kapalı"
		},
		Environment = {
			Clouds = {
				Cover = {0.5, 0.5},
				Density = {0.8, 0.8}
			},
			Atmosphere = {
				Density = {0.3, 0.3}
			}
		}
	},
	
	[5] = {
		State = "Bitki için uygun toprak koşulları sağlanır. Böylece sulama sistemi bu döngüyle devam etmiş olur. Herhangi bir insan gücüne gerek kalmadan bitkinin yaşaması sağlanır.",
		Possibilities = "",
		Reality = {
			SpeedUp = "-",
			Suitable = "-",
			Cost = "-",
			Actualizable = "-"
		},
		Properties = {
			Weather = weatherTypes[2][math.random(1, 2)],
			SoilMoisture = "Bitki için uygun.",
			Fullness = "Dolu",
			Awning = "Kapalı"
		},
		Environment = {
			Clouds = {
				Cover = {0.5, 0.5},
				Density = {0.8, 0.8}
			},
			Atmosphere = {
				Density = {0.3, 0.3}
			}
		}
	}
}

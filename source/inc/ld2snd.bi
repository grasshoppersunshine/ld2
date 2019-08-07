TYPE LD2musicData
	id AS INTEGER
	filepath AS STRING * 16
	loopmusic AS INTEGER
END TYPE

DECLARE SUB SoundAdapter.Init ()
DECLARE SUB SoundAdapter.Release ()
DECLARE SUB SoundAdapter.LoadMusic (filepath AS STRING)
DECLARE SUB SoundAdapter.PlayMusic ()
DECLARE SUB SoundAdapter.StopMusic ()
DECLARE SUB SoundAdapter.SetMusicVolume (vol AS INTEGER)
DECLARE SUB SoundAdapter.SetMusicLoop (doLoop AS INTEGER)
DECLARE SUB SoundAdapter.PlaySound (id AS INTEGER)

DECLARE SUB LD2.InitSound ()
DECLARE SUB LD2.ReleaseSound ()
DECLARE SUB LD2.AddMusic (id AS INTEGER, filepath AS STRING, loopmusic AS INTEGER)
DECLARE SUB LD2.LoadMusic (id AS INTEGER)
DECLARE SUB LD2.PlayMusic (id AS INTEGER)
DECLARE SUB LD2.StopMusic ()
DECLARE SUB LD2.PlaySound (id AS INTEGER)
DECLARE SUB LD2.FadeInMusic (id AS INTEGER)
DECLARE SUB LD2.FadeOutMusic ()


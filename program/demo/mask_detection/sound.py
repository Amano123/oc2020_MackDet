#!/usr/bin/env python
# -*- coding: utf-8 -*-
import pyaudio
import wave
from time import sleep
import threading

CHUNK = 1024


class AudioPlayer:
    """ A Class For Playing Audio """

    def __init__(self):
        self.audio_file = ""

        # 止める用のフラグ
        self.paused = threading.Event()

    def setAudioFile(self, audio_file):
        self.audio_file = audio_file

    def playAudio(self):
        if (self.audio_file == ""):
            return
        self.wf = wave.open(self.audio_file, "rb")
        p = pyaudio.PyAudio()

        self.stream = p.open(format=p.get_format_from_width(self.wf.getsampwidth()),
                             channels=self.wf.getnchannels(),
                             rate=self.wf.getframerate(),
                             output=True)

        data = self.wf.readframes(CHUNK)

        # play stream (3)
        while len(data) > 0:
            # もし、止めるフラグが立ってたら
            if self.paused.is_set():
                # 再生を止める
                self.stream.stop_stream()
                # フラグを初期状態に
                self.paused.clear()
                break
            self.stream.write(data)
            data = self.wf.readframes(CHUNK)

        # stop stream (4)
        self.stream.stop_stream()
        self.stream.close()
        # close PyAudio (5)
        p.terminate()


def play(player):
    # 再生は別のスレッドでする
    audio_thread = threading.Thread(target=player.playAudio)
    audio_thread.start()


if __name__ == "__main__":
    player1 = AudioPlayer()
    player1.setAudioFile("1.wav")
    player2 = AudioPlayer()
    player2.setAudioFile("2.wav")

    play(player1)
    # 例えば0,5秒後に別の音源に変える
    sleep(0.5)
    # 1を止めて
    player1.paused.set()
    # 2を再生
    play(player2)


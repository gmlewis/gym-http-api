// -*- compile-command: "go run main.go"; -*-

// pong is a sample program using the Go OpenAI Gym binding.
package main

import (
	"fmt"
	"image"
	"image/color"
	"image/png"
	"os"

	gym "github.com/gmlewis/gym-http-api/binding-go"
)

const BaseURL = "http://localhost:5000"

func main() {
	client, err := gym.NewClient(BaseURL)
	must(err)

	// Create environment instance.
	id, err := client.Create("Pong-v0")
	if err != nil {
		fmt.Fprintln(os.Stderr, "Error:", err)
		fmt.Fprintln(os.Stderr, "You might have to run `pip install gym[atari]`.")
		os.Exit(1)
	}
	defer client.Close(id)

	// Test space information APIs.
	actSpace, err := client.ActionSpace(id)
	must(err)
	fmt.Printf("Action space: %+v\n", actSpace)
	_, err = client.ObservationSpace(id)
	must(err)
	// fmt.Printf("Observation space: %+v\n", obsSpace)

	// Take a few random steps
	fmt.Println("\nStarting new episode...")
	_, err = client.Reset(id)
	must(err)
	var lastObservation interface{}
	for i := 1; i <= 5; i++ {
		fmt.Println("Observation #", i)
		action, err := client.SampleAction(id)
		must(err)
		fmt.Println("Taking action:", action)
		var reward float64
		lastObservation, reward, _, _, err = client.Step(id, action, false)
		fmt.Println("reward:", reward)
		must(err)
	}

	// Produce an image from the last video frame and
	// save it to pong.png.
	fmt.Println("Writing image to /tmp/pong.png...")
	frame := lastObservation.([][][]float64)
	img := image.NewRGBA(image.Rect(0, 0, len(frame[0]), len(frame)))
	for rowIdx, row := range frame {
		for colIdx, col := range row {
			color := color.RGBA{
				R: uint8(col[0]),
				G: uint8(col[1]),
				B: uint8(col[2]),
				A: 0xff,
			}
			img.SetRGBA(colIdx, rowIdx, color)
		}
	}
	outFile, err := os.Create("/tmp/pong.png")
	must(err)
	defer outFile.Close()
	must(png.Encode(outFile, img))
}

func must(err error) {
	if err != nil {
		panic(err)
	}
}

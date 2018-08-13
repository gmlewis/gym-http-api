// -*- compile-command: "go run main.go"; -*-

// copy is a sample program using the Go OpenAI Gym binding.
package main

import (
	"fmt"

	gym "github.com/gmlewis/gym-http-api/binding-go"
)

const BaseURL = "http://localhost:5000"

func main() {
	client, err := gym.NewClient(BaseURL)
	must(err)

	// Create environment instance.
	id, err := client.Create("Copy-v0")
	must(err)
	defer client.Close(id)

	// Test space information APIs.
	actSpace, err := client.ActionSpace(id)
	must(err)
	fmt.Printf("Action space: %+v\n", actSpace)
	obsSpace, err := client.ObservationSpace(id)
	must(err)
	fmt.Printf("Observation space: %+v\n", obsSpace)

	// Start monitoring to a temp directory.
	must(client.StartMonitor(id, "/tmp/copy-monitor", true, false, false))

	// Run through an episode.
	fmt.Println("\nStarting new episode...")
	obs, err := client.Reset(id)
	must(err)
	fmt.Println("First observation:", obs)
	for {
		// Sample a random action to take.
		act, err := client.SampleAction(id)
		must(err)
		// act := rand.Intn(obsSpace.N)
		fmt.Println("Taking action:", act)

		// Unnecessary; demonstrates the ContainsAction API.
		c, err := client.ContainsAction(id, act)
		must(err)
		if !c {
			panic(fmt.Sprintf("sampled action %v not contained in space", act))
		}

		// Take the action, getting a new observation, a reward,
		// and a flag indicating if the episode is done.
		newObs, rew, done, _, err := client.Step(id, act, false)
		must(err)
		obs = newObs
		fmt.Println("reward:", rew, " -- observation:", obs)
		if done {
			break
		}
	}

	must(client.CloseMonitor(id))

	// Uncomment the code below to upload to the Gym website.
	// Note: you must set the OPENAI_GYM_API_KEY environment
	// variable or set the second argument of Upload() to a
	// non-empty string.
	//
	//     must(client.Upload("/tmp/copy-monitor", "", ""))
	//
}

func must(err error) {
	if err != nil {
		panic(err)
	}
}

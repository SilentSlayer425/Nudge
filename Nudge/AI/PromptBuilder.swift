//
//  PromptBuilder.swift
//  Nudge
//
//  Created by Sai on 7/31/26.
//

import Foundation


enum PromptBuilder {


    /// Expands a session goal into an allow/block policy of macOS application
    /// names. Runs once per session. Third-person, data-labeling framing —
    /// this is never phrased so the model could answer as the user.
    static func policyExpansionPrompt(goal: String) -> String {

        """
        A person is starting a focused work session with this goal:

        Goal: \(goal)

        Task: build two lists of macOS application names — real applications
        exactly as they would appear as the frontmost (active) app on a Mac,
        for example "Xcode", "Terminal", "Safari", "Discord", "Slack", "Mail".
        These must be application names, not descriptions of activities.

        Rules:
        - Each list entry must be exactly one application name, written the
          way macOS shows it in the menu bar: no ".app" suffix, no
          parenthetical alternatives, no "or" / "such as".
        - Never combine multiple apps into one entry (do not write things
          like "Discord/Slack" or "Discord and Slack" — write "Discord" and
          "Slack" as two separate entries).
        - "allow" must contain exactly 6 to 12 entries: applications that
          directly support working toward this goal (editors, terminals,
          documentation, and tools specific to the goal).
        - "block" must contain exactly 6 to 12 entries: common, well-known
          consumer apps that are unrelated to this goal and would be a
          distraction (chat, social, video, games, streaming, shopping).
        - An application must not appear in both lists.
        - Chat and social apps such as Discord, Slack, Messages, and
          WhatsApp belong in "block" unless the goal is explicitly about
          communicating with a team.
        - Every entry must be a real application that ships as a macOS app
          and can be the frontmost window. Command-line tools, package
          managers, websites, services, and libraries are not applications
          and must never appear in either list (do not write things like
          "Homebrew", "npm", "GitHub", "Stack Overflow").
        - "allow" must also include the everyday companion applications
          someone pursuing this goal would unavoidably use alongside their
          main tool — a terminal, a web browser for reading documentation,
          a notes app, and any first-party tooling the goal implies (for
          a goal involving Xcode, that includes Simulator). Omitting these
          is a failure: they are used constantly during real work.

        Write brief reasoning first, then the allow list, then the block
        list.
        """

    }


    /// Classifies a single unknown application against the goal. Third-person,
    /// data-labeling framing. Reasoning is requested before the verdict so the
    /// model cannot commit to an answer before it has reasoned about it.
    static func classificationPrompt(goal: String, app: String) -> String {

        """
        Goal for a focused work session: \(goal)

        Application currently in the foreground on the person's Mac: \(app)

        Task: decide whether using this application plausibly serves the
        stated goal.

        Judge the application by its typical, everyday primary purpose —
        not by an unusual or hypothetical way it could theoretically be
        used for the goal. General-purpose chat, social, video, streaming,
        gaming, and shopping apps (for example Discord, Slack, Messages,
        WhatsApp, YouTube, Instagram, Netflix, Spotify) count as NOT
        focused unless the goal explicitly names that application or
        explicitly requires team communication. When genuinely unsure,
        prefer the lower confidence score rather than a generous
        justification.

        Write brief reasoning first, then decide whether this counts as
        focused, and give a confidence score from 0 to 100.
        """

    }

}

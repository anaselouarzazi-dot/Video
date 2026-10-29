import { z } from "zod";
import {
  AbsoluteFill,
  interpolate,
  spring,
  useCurrentFrame,
  useVideoConfig,
} from "remotion";

export const introSchema = z.object({
  title: z.string(),
  subtitle: z.string(),
});

export const Intro: React.FC<z.infer<typeof introSchema>> = ({ title, subtitle }) => {
  const frame = useCurrentFrame();
  const { fps, durationInFrames } = useVideoConfig();

  const enter = spring({ frame, fps, config: { damping: 200 } });
  const exit = interpolate(frame, [durationInFrames - 15, durationInFrames], [1, 0], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });
  const subtitleOpacity = interpolate(frame, [20, 40], [0, 1], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });

  return (
    <AbsoluteFill
      style={{
        backgroundColor: "#0b0d17",
        color: "#f5f3ee",
        fontFamily: '"Helvetica Neue", Arial, sans-serif',
        justifyContent: "center",
        alignItems: "center",
        opacity: exit,
      }}
    >
      <h1
        style={{
          fontSize: 120,
          fontWeight: 600,
          letterSpacing: "-0.03em",
          margin: 0,
          transform: `translateY(${(1 - enter) * 40}px)`,
          opacity: enter,
        }}
      >
        {title}
      </h1>
      <p style={{ fontSize: 40, marginTop: 24, opacity: subtitleOpacity * 0.7 }}>{subtitle}</p>
    </AbsoluteFill>
  );
};
